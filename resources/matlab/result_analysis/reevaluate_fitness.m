% extra_stats.mat
%     fitness2: big matrix containing the second evaluated fitness for all robots
%         size nb_gen x gen_size
function reevaluate_fitness(app)
% Evaulate the fitness of the best robot of each generation in the added results
% with visualization
    if app.WithVisualizationCheckBox.Value == true
        with_vis = true;
    else
        with_vis = false;
    end
    plot_colors = [  1,   0,   0;
                   0.7, 0.4,   0;
                     0,   1,   0;
                     0,   0,   1];
    num_results = length(app.targets_to_compare);
    if num_results == 0
        msgbox('Add single results to comparison target to re-evaluate corresponding fitness');
        return
    end

    for i = 1 : num_results
        if app.targets_to_compare{i}.isgroup
            msgbox('There are virutal results in the comporison targets, abort.');
            return
        end
    end

    if strcmp(app.ReEvaluationType.SelectedObject.Text, 'All')
        mode = "all";
    elseif strcmp(app.ReEvaluationType.SelectedObject.Text, 'Best of Gen')
        mode = "best";
    end

    wb_result = waitbar(double(1) / double(num_results), ['Processing 1 / ', num2str(num_results)], 'Name', 'Re-evaluate fitness');
    for i_result = 1 : num_results
        result = load_target_result(app, false, app.targets_to_compare{i_result}.id);
        nb_gen = result.evo_params.nb_gen;
        gen_size = result.evo_params.gen_size;

        sim_configs = video_simulation_configs(result.env);
        sim_configs.robot_color = plot_colors(1,:);
        sim_configs.result_id = result.id;
        if ~with_vis
            sim_configs.mode = 'no_visualization';
        end

        extra_stats_path = fullfile(result.path, 'extra_stats.mat');
        if isfield(app.results{result.id}, 'extra_stats')
            extra_stats = app.results{result.id}.extra_stats;
        elseif isfile(extra_stats_path)
            extra_stats_container = load(extra_stats_path);
            extra_stats = extra_stats_container.extra_stats;
            app.results{result.id}.extra_stats = extra_stats;
        else
            extra_stats = {};
        end

        if mode == "all"
            if ~isfield(extra_stats, 'fitness2')
                extra_stats.fitness2 = nan(nb_gen + 1, 30);
                extra_stats.fitness2_gen = 0;
                extra_stats.fitness2_robot = 0;
            end
            wb_gen = waitbar(double(extra_stats.fitness2_gen + 1) / double(nb_gen + 1), ...
                             ['Processing ', num2str(extra_stats.fitness2_gen + 1), ' / ', num2str(nb_gen + 1)], ...
                             'Name', result.name);
            for gen_id = extra_stats.fitness2_gen : nb_gen % go through every generation
                sim_configs.gen_id = gen_id;
                wb_robot = waitbar(double(extra_stats.fitness2_robot + 1) / double(gen_size), ...
                                   ['Processing ', num2str(extra_stats.fitness2_robot + 1), ' / ', num2str(gen_size)], ...
                                   'Name', ['Gen: ', num2str(gen_id)]);
                for i_robot = extra_stats.fitness2_robot : gen_size - 1
                    sim_configs.robot_id = i_robot;
                    sim_report = simulate_robot(app, sim_configs);
                    if sim_report.done
                        extra_stats.fitness2(gen_id + 1, i_robot + 1) = sim_report.fitness;
                    end

                    extra_stats.fitness2_robot = i_robot + 1; % in case evaluation is terminated during the loop
                    waitbar(double(i_robot + 2) / double(gen_size), wb_robot, sprintf("Processing %d / %d", i_robot + 2, gen_size));
                end

                extra_stats.fitness2_robot = 0;
                extra_stats.fitness2_gen = gen_id + 1;
                app.results{result.id}.extra_stats = extra_stats;

                % Save results
                if mod(gen_id, 10) == 0
                    save(fullfile(result.path, 'extra_stats.mat'), 'extra_stats', '-v7.3');
                end
                close(wb_robot)
                waitbar(double(gen_id + 2) / double(nb_gen + 1), wb_gen, sprintf("Processing %d / %d", gen_id + 2, nb_gen + 1));
            end
            close(wb_gen)
        elseif mode =="best"
            gen_start = 0;
            if isfield(result.stat, 'visual_best_fits')
                gen_start = length(result.stat.visual_best_fits);
            end
            wb_gen = waitbar(double(gen_start + 1) / double(nb_gen + 1), ...
                             ['Processing ', num2str(gen_start + 1), ' / ', num2str(nb_gen + 1)], ...
                             'Name', result.name);
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
                app.results{result.id}.stat.visual_best_fits(gen_id + 1) = sim_report.fitness;
                app.results{result.id}.stat.visual_best_fits_info{gen_id + 1} = ...
                    [best_robot_gen, best_robot_id, best_robot_fid1, best_robot_fid2];

                % Save results to the stat file
                if mod(gen_id, 20) == 0
                    stat = app.results{result.id}.stat;
                    save(fullfile(result.path, 'stat.mat'), 'stat', '-v7.3');
                    stat = {}; % so that next time result.stat is modified, there won't be a copy
                               % of stat being created
                end
                waitbar(double(gen_id + 2) / double(nb_gen + 1), wb_gen, sprintf("Processing %d / %d", gen_id + 2, nb_gen + 1));
            end
            close(wb_gen);
        end
        waitbar(double(i_result + 1) / double(num_results), wb_result, sprintf("Processing %d / %d", i_result + 1, num_results));
    end
    close(wb_result);
end
