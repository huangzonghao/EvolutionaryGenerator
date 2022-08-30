% Why calibration:
%     The recorded fitness of robots during training may contain noises due to
%     multithreading executing, and irrepeatibility of simualtion itself,
%     especially comparing to results of simulation with visualization. So we
%     want to re-run the simualtion with visualization in single thread for all
%     the selected robot in the video, so that their actually performance and the
%     recorded fitness don't vary too much.
% Method:
%     Repeatedly select the best robot of the given gen, put it into simulation,
%     update its fitness if necessary, until the recorded fitness and the simualted
%     fitess don't differ for more than 5%
function calibrate_for_video(app)
    % plot_colors = [  1,   0,   0;
                   % 0.7, 0.4,   0;
                     % 0,   1,   0;
                     % 0,   0,   1];
    gen_order = [0, 500, 1000, 1500, 2000];
    result_names = {'H0', 'H15', 'H25', 'H30'};

    num_results = length(app.targets_to_compare);

    if num_results == 0
        msgbox('Add a single results to comparison target to calibrate');
        return
    end

    for i = 1 : num_results
        if app.targets_to_compare{i}.isgroup
            msgbox('There are virutal results in the comporison targets, abort.');
            return
        end
    end

    wb_result = waitbar(double(0), '', 'Name', 'Fitness Calibration for Videos');
    wb_result.Children.Title.Interpreter = 'none';
    for i_target = 1 : num_results
        has_update = false;
        load_result_robots(app, app.targets_to_compare{i_target}.id);
        result = load_target_result(app, false, app.targets_to_compare{i_target}.id);
        waitbar(double(i_target) / double(num_results), wb_result, ...
                sprintf("Processing %d / %d (Curr: %s)", i_target, num_results, result.name));
        sim_configs = app.video_simulation_configs(result.env);
        sim_configs.result_id = result.id;
        % sim_configs.robot_color = plot_colors(i_target,:);
        sim_configs.mode = 'no_visualization';
        wb_gen = waitbar(double(0), '', 'Name', result.name);
        for i_gen = 1 : length(gen_order)
            gen = gen_order(i_gen);
            waitbar(double(i_gen) / double(length(gen_order)), wb_gen, ...
                    sprintf("Processing %d / %d, (Curr gen: %d)", i_gen, length(gen_order), gen));
            current_gen_archive = app.results{result.id}.archive{gen + 1};
            redo_archive = false;
            update_counter = 0;
            while true
                clean_gen_archive = current_gen_archive(current_gen_archive(:,3) ~= 0, :);
                clean_fitness = clean_gen_archive(:, 5);
                [recorded_fitness, clean_idx] = max(clean_fitness);
                sim_configs.gen_id = clean_gen_archive(clean_idx, 1);
                sim_configs.robot_id = clean_gen_archive(clean_idx, 2);
                sim_report = simulate_robot(app, sim_configs);

                if abs(sim_report.fitness - recorded_fitness) < abs(0.05 * recorded_fitness)
                    if redo_archive
                        regenerate_archive_map_kernel(app, result.id);
                        current_gen_archive = app.results{result.id}.archive{gen + 1};
                        redo_archive = false;
                        continue
                    else
                        break
                    end
                end

                update_counter = update_counter + 1;
                disp(sprintf("\n\nfid1: %d, fid2: %d, old fit: %.4f, new fit: %.4f\n" + ...
                             "Number of Updates %d", ...
                             clean_gen_archive(clean_idx, 3), clean_gen_archive(clean_idx, 4), ...
                             recorded_fitness, sim_report.fitness, update_counter));
                full_idx = find(ismember(current_gen_archive, clean_gen_archive(clean_idx, :), 'rows'));
                current_gen_archive(full_idx, 5) = sim_report.fitness;
                app.results{result.id}.robots(sim_configs.robot_id + 1, 9, sim_configs.gen_id + 1) = sim_report.fitness;
                redo_archive = true;
                has_update = true;
            end
            app.results{result.id}.archive{gen + 1} = current_gen_archive;
        end
        close(wb_gen);

        if has_update
            robots = app.results{result.id}.robots;
            archive = app.results{result.id}.archive;
            save(fullfile(result.path, 'robots.mat'), 'robots', '-v7.3');
            save(fullfile(result.path, 'archive.mat'), 'archive', '-v7.3');
        end
    end
    close(wb_result);
    msgbox('Calibration done');
end
