function simulate_for_video(app)
% Testing mode when only one result added to comparison target
% Production mode when multiple results added
    plot_colors = [  1,   0,   0;
                   0.7, 0.4,   0;
                     0,   1,   0;
                     0,   0,   1];
    gen_order = [0, 500, 1000, 1500, 2000];

    if length(app.targets_to_compare) == 0
        msgbox('Add a single result to comparison target to run video simulation');
        return
    end

    for i = 1 : length(app.targets_to_compare)
        if app.targets_to_compare{i}.isgroup
            msgbox('There are virutal results in the comporison targets, abort.');
            return
        end
    end

    if length(app.targets_to_compare) == 1
        % Testing mode when only one result added
        gen_id = app.VideoGenIDField.Value;
        if gen_id > 2000 || gen_id < 0
            msgbox('Enter a gen number in range [0, 2000]');
            return
        end
        robot_info = simulate_for_one(app, app.targets_to_compare{1}.id, plot_colors(1,:), gen_id, false);
        disp(sprintf("Simulated robot: result %s, gen %d, id %d, fitness %d, fid1 %d, fid2 %d", robot_info.result_name, robot_info.gen, robot_info.id, robot_info.fitness, robot_info.fid1, robot_info.fid2));
    else
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
        video_report = {};
        for i_gen = 1 : length(gen_order)
            new_gen = {};
            gen_id = gen_order(i_gen);
            new_gen.id = gen_id;
            for i_target = 1 : length(app.targets_to_compare)
                robot_info = simulate_for_one(app, app.targets_to_compare{i_target}.id, plot_colors(i_target,:), gen_id, false);
                new_gen.(['robot_', num2str(i_target)]) = robot_info;
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
                pause(1); % delay for one second, so that the screen recorder has some time to response
            end
            video_report.(['gen_', num2str(gen_id)]) = new_gen;
            % exportgraphics(fig, [app.CompPlotNameField.Value '_video_archive_gen_', num2str(gen_id), '_.png']);
            ax.NextPlot = 'replace';
        end
        % Dump files
        video_report.timestamp = datestr(now,'yyyy-mm-dd HH:MM:SS');
        filename = strcat('./video_report_', datestr(now, 'yyyymmdd_HHMMSS'), '.json');
        new_file_spec = fopen(filename, "wt");
        fprintf(new_file_spec, jsonencode(video_report, 'PrettyPrint', true));
        fclose(new_file_spec);
    end
end

function robot_info = simulate_for_one(app, result_id, robot_color, gen_id, async)
    result = load_target_result(app, false, result_id);
    robot_info = {};
    robot_info.result_name = result.name;
    robot_info.archive_gen = gen_id;

    % now load the best robot of that gen_id
    current_gen_archive = result.archive{gen_id + 1};
    clean_gen_archive = current_gen_archive(current_gen_archive(:,3) ~= 0, :);
    clean_fitness = clean_gen_archive(:, 5);
    [clean_max_fitness, clean_max_idx] = max(clean_fitness);
    robot_info.fitness = clean_max_fitness;
    robot_info.gen = clean_gen_archive(clean_max_idx, 1);
    robot_info.id = clean_gen_archive(clean_max_idx, 2);
    robot_info.fid1 = clean_gen_archive(clean_max_idx, 3);
    robot_info.fid2 = clean_gen_archive(clean_max_idx, 4);

    robot_file_buffer = readmatrix(fullfile(result.path, strcat('/robots/', num2str(robot_info.gen), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
    current_robot = robot_file_buffer(robot_file_buffer(:, 2)==robot_info.id, :);

    robot_info.f1 = current_robot(9);
    robot_info.f2 = current_robot(10);

    % ground video settings
    % env_color_str = num2str([0.5, 0.5, 0.5], '%.5f,'); % for ground
    % camera_str = num2str([7, -8, 6, 7, 0, 0], '%.2f,'); % for ground
    % light_str = num2str([0, 0, -1], '%.2f,');
    % sine video settings
    % env_color_str = num2str([0.5, 0.5, 0.5], '%.5f,'); % for sine
    % camera_str = num2str([0, -8, 6, 0, 0, 0], '%.2f,'); % for sine
    % light_str = num2str([0, 0, -1], '%.2f,');
    % valley video settings
    env_color_str = num2str([0.5, 0.5, 0.5], '%.5f,'); % for sine
    camera_str = num2str([0, -8, 6, 0, 0, 0], '%.2f,'); % for sine
    light_str = num2str([0, 0, -1], '%.2f,');

    % camera_str = num2str([7, -5, 1, 7, 0, 0], '%.2f,'); % for ground
    % camera_str = num2str([2.5, -4, 4, 2.5, 0, 0], '%.2f,'); % for valley
    % Run simulation
    dv = current_robot(12:end);
    dv = dv(~isnan(dv));
    time_out = 60; % TODO: should read from sim_params.xml
    dv_str = num2str(dv, '%.5f,');
    dv_str = dv_str(1:end-1);
    dv_str = dv_str(~isspace(dv_str));
    canvas_str = num2str([1600, 270], '%d,');
    canvas_str = canvas_str(1:end-1);
    canvas_str = canvas_str(~isspace(canvas_str));
    color_str = num2str(robot_color, '%.5f,');
    color_str = color_str(1:end-1);
    color_str = color_str(~isspace(color_str));
    env_color_str = env_color_str(1:end-1);
    env_color_str = env_color_str(~isspace(env_color_str));
    camera_str = camera_str(1:end-1);
    camera_str = camera_str(~isspace(camera_str));
    light_str = light_str(1:end-1);
    light_str = light_str(~isspace(light_str));
    cmd_str = "";
    if async
        cmd_str = "start ";
    end
    cmd_str = cmd_str + fullfile(app.evogen_exe_path, app.simulator_name) + ...
              " --robot_type mesh " + ...
              " --sim_param " + fullfile(result.path, app.sim_params_filename) + ...
              " --sim_time " + num2str(time_out) + ...
              " --color=" + color_str + ...
              " --env_color=" + env_color_str + ...
              " --camera=" + camera_str + ...
              " --light=" + light_str + ...
              " --canvas_size=" + canvas_str + ...
              " --design_vector=" + dv_str;
    system(cmd_str);
end
