function simulate_for_video(app)
% Testing mode when only one result added to comparison target
% Production mode when multiple results added
    production_mode = false;
    export_plots = false;

    plot_colors = [  1,   0,   0;
                   0.7, 0.4,   0;
                     0,   1,   0;
                     0,   0,   1];
    gen_order = [0, 500, 1000, 1500, 2000];
    result_names = {'H0', 'H15', 'H25', 'H30'};

    num_results = length(app.targets_to_compare);

    if num_results == 0
        msgbox('Add a single result to comparison target to run video simulation');
        return
    end

    for i = 1 : num_results
        if app.targets_to_compare{i}.isgroup
            msgbox('There are virutal results in the comporison targets, abort.');
            return
        end
    end

    if production_mode && num_results ~= 4
        msgbox('Add the H0, H15, H25, H30 samples of the environemnt');
        return
    end

    if production_mode
        video_report = {};
        gen_reports = {};
        for i = 1 : length(gen_order)
            gen_reports{i}.id = gen_order(i);
        end
    else
        gen_order = app.VideoGenIDField.Value;
    end

    for i_target = 1 : num_results
        result = load_target_result(app, false, app.targets_to_compare{i_target}.id);
        sim_configs = video_simulation_configs(result.env);
        sim_configs.result_id = result.id;
        sim_configs.robot_color = plot_colors(i_target,:);
        if production_mode
            sim_configs.record_frame = true;
        end
        for i_gen = 1 : length(gen_order)
            gen = gen_order(i_gen);

            % now load the best robot of that gen
            current_gen_archive = result.archive{gen + 1};
            clean_gen_archive = current_gen_archive(current_gen_archive(:,3) ~= 0, :);
            clean_fitness = clean_gen_archive(:, 5);
            [clean_max_fitness, clean_max_idx] = max(clean_fitness);
            robot_gen = clean_gen_archive(clean_max_idx, 1);
            robot_id = clean_gen_archive(clean_max_idx, 2);
            if production_mode
                sim_configs.frame_output_name = strcat('g', num2str(gen), '_', result_names{i_target});
                robot_info = {};
                robot_info.result_name = result.name;
                robot_info.archive_gen = gen;
                robot_info.fitness = clean_max_fitness;
                robot_info.fid1 = clean_gen_archive(clean_max_idx, 3);
                robot_info.fid2 = clean_gen_archive(clean_max_idx, 4);
                robot_info.f1 = result.robots(robot_id, 7, gen);
                robot_info.f2 = result.robots(robot_id, 8, gen);
            end

            sim_configs.gen_id = robot_gen;
            sim_configs.robot_id = robot_id;
            sim_report = simulate_robot(app, sim_configs);

            if production_mode
                robot_info.visual_fitness = sim_report.visual_fitness;
                gen_reports{i_gen}.(['robot_', num2str(i_target)]) = robot_info;
            end
        end
    end

    if num_results == 1
        disp(sprintf("\n\nSimulated robot: result %s, gen %d, id %d\n" + ...
                     "\trecorded fitness %.4f, simulated fitness %.4f\n" + ...
                     "\tfid1 %d, fid2 %d", ...
                     result.name, robot_gen, robot_id, ...
                     clean_max_fitness, sim_report.fitness, ...
                     clean_gen_archive(clean_max_idx, 3), clean_gen_archive(clean_max_idx, 4)));
    end

    % Dump files and generate plots
    if production_mode
        if export_plots
            % Somehow the following code won't work, as matlab wouldn't let me create
            % an axes on top of the existing heatmap chart
            % % fig = generate_combined_archive_map(app);
            % fig = gcf;
            % fig.Position(3:4) = [580, 540]; % manually picked value so that the two plots overlap perfectly.
            % colormap(fig, flipud(gray))
            % ax = axes(fig);
            source_hm = gca;
            fig = figure();
            fig.Position = [100, 100, 580, 540]; % manually picked value so that the two plots overlap perfectly.
            copyobj(source_hm, fig);
            colormap(fig, flipud(gray))
            hm = fig.Children(1);
            hm.NodeChildren(3).YDir='normal';
            hm_s = struct(hm);
            hm_s.XAxis.TickLabelRotation = 0; % undocumented function
            ax = axes(fig);
            for i_gen = 1 : length(gen_order)
                for i_target = 1 : num_results
                    robot_info = gen_reports{i_gen}.(['robot_', num2str(i_target)])
                    plot(ax, robot_info.f2, robot_info.f1, '.', 'MarkerSize', 45, 'Color', plot_colors(i_target,:));
                    if i_target == 1
                        ax.Color = 'none';
                        ax.Position(3) = 0.72;
                        ax.XLim = [-0.05, 1.05];
                        ax.YLim = [-0.05, 1.05];
                        ax.XTick = [];
                        ax.YTick = [];
                        ax.Box = 'on';
                        % ax.BoxStyle = 'full'; % enable this to find a perfect figure size that overlaps two axes
                        ax.NextPlot = 'add';
                    end
                end
                exportgraphics(fig, [app.CompPlotNameField.Value '_video_archive_gen_', num2str(gen), '_.png']);
                ax.NextPlot = 'replace';
            end
        end

        for i = 1 : length(gen_order)
            video_report.(['gen_', num2str(gen_order(i))]) = gen_reports{i};
            gen_reports{i}.id = gen_order(i);
        end
        video_report.timestamp = datestr(now,'yyyy-mm-dd HH:MM:SS');
        filename = strcat('./video_report_', datestr(now, 'yyyymmdd_HHMMSS'), '.json');
        new_file_spec = fopen(filename, "wt");
        fprintf(new_file_spec, jsonencode(video_report, 'PrettyPrint', true));
        fclose(new_file_spec);
    end
end
