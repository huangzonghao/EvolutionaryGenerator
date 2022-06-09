function evaluate_with_visualization(app)
% Evaulate the fitness of the best robot of each generation in the added results
% with visualization
    plot_colors = [  1,   0,   0;
                   0.7, 0.4,   0;
                     0,   1,   0;
                     0,   0,   1];
    num_results = length(app.targets_to_compare);
    if num_results == 0
        msgbox('Add single results to comparison target to evaluate with visualization');
        return
    end

    for i = 1 : num_results
        if app.targets_to_compare{i}.isgroup
            msgbox('There are virutal results in the comporison targets, abort.');
            return
        end
    end

    wb_result = waitbar(double(1) / double(num_results), ['Processing 1 / ', num2str(num_results)], 'Name', 'Evaluation with visualization');
    for i_result = 1 : num_results
        result = load_target_result(app, false, app.targets_to_compare{i_result}.id);
        gen_start = 0;
        if isfield(result.stat, 'visual_best_fits')
            gen_start = length(result.stat.visual_best_fits);
        end
        nb_gen = result.evo_params.nb_gen;
        wb_gen = waitbar(double(gen_start + 1) / double(nb_gen + 1), ...
                         ['Processing ', num2str(gen_start + 1), ' / ', num2str(nb_gen + 1)], ...
                         'Name', result.name);

        sim_configs = video_simulation_configs(result.env);
        sim_configs.robot_color = plot_colors(1,:);
        sim_configs.result_id = result.id;

        for gen_id = gen_start : nb_gen % go through every generation
            current_gen_archive = result.archive{gen_id + 1};
            clean_gen_archive = current_gen_archive(current_gen_archive(:,3) ~= 0, :);
            clean_fitness = clean_gen_archive(:, 5);
            [clean_max_fitness, clean_max_idx] = max(clean_fitness);
            best_robot_fitness = clean_max_fitness;
            best_robot_gen = clean_gen_archive(clean_max_idx, 1);
            best_robot_id = clean_gen_archive(clean_max_idx, 2);
            best_robot_fid1 = clean_gen_archive(clean_max_idx, 3);
            best_robot_fid2 = clean_gen_archive(clean_max_idx, 4);

            sim_configs.gen_id = best_robot_gen;
            sim_configs.robot_id = best_robot_id;
            sim_report = simulate_robot(app, sim_configs);
            app.results{result.id}.stat.visual_best_fits(gen_id + 1) = sim_report.visual_fitness;
            app.results{result.id}.stat.visual_best_fits_info{gen_id + 1} = ...
                [best_robot_gen, best_robot_id, best_robot_fid1, best_robot_fid2];

            waitbar(double(gen_id + 2) / double(nb_gen + 1), wb_gen, sprintf("Processing %d / %d", gen_id + 2, nb_gen + 1));

            % Save results to the stat file
            if mod(gen_id, 20) == 0
                stat = app.results{result.id}.stat;
                save(fullfile(result.path, 'stat.mat'), 'stat', '-v7.3');
                stat = {}; % so that next time result.stat is modified, there won't be a copy
                           % of stat being created
            end
        end
        close(wb_gen);
        waitbar(double(i_result + 1) / double(num_results), wb_result, sprintf("Processing %d / %d", i_result + 1, num_results));
    end
    close(wb_result);
end
