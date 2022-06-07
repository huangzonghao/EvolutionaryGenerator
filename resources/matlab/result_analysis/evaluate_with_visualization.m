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

        sim_configs = {};
        sim_configs.robot_color = plot_colors(1,:);
        sim_configs.async = false;
        sim_configs.record_frame = false;
        sim_configs.canvas_size = [1380, 270];
        sim_configs.fov = 20;
        if strcmp(result.env, 'ground')
            sim_configs.env_color = [0.9, 0.9, 0.9];
            sim_configs.camera= [5, -20, 10, 5, 0, 2];
            sim_configs.light= [0, 0, -1];
        elseif strcmp(result.env, 'sine')
            sim_configs.env_color = [0.8, 0.8, 0.8];
            sim_configs.camera = [0, -22, 12, 0, 0, 0];
            sim_configs.light = [1, 0, -2];
        elseif strcmp(result.env, 'valley')
            sim_configs.env_color = [0.8, 0.8, 0.8];
            sim_configs.camera = [-2, -15, 18, -2, 0, 0];
            sim_configs.light = [0, 0, -1];
            sim_configs.canvas_size = [690, 270];
        else
            msgbox(['Unknown environment encountered ', result.env]);
        end

        for gen_id = gen_start : nb_gen % go through every generation
            sim_configs.gen_id = gen_id;
            robot_info = simulate_for_one(app, result, sim_configs);
            % TODO: do not change result, change app.result
            app.results{result.id}.stat.visual_best_fits(gen_id + 1) = robot_info.best_fitness_visual;
            app.results{result.id}.stat.visual_best_fits_info{gen_id + 1} = ...
                [robot_info.gen, robot_info.id, robot_info.fid1, robot_info.fid2];

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

% sim_configs:
%     result_id (int)
%     robot_color (3d vector)
%     gen_id (int)
%     async (bool)
%     record_frame (bool)
function robot_info = simulate_for_one(app, result, sim_configs)
    robot_info = {};
    robot_info.result_name = result.name;
    robot_info.archive_gen = sim_configs.gen_id;

    % now load the best robot of that sim_configs.gen_id
    current_gen_archive = result.archive{sim_configs.gen_id + 1};
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

    cmd_str = "";

    if sim_configs.async
        cmd_str = "start ";
    end

    cmd_str = cmd_str + fullfile(app.evogen_exe_path, app.simulator_name);

    if isfield(sim_configs, 'canvas_size')
        canvas_size = sim_configs.canvas_size;
        canvas_str = num2str(canvas_size, '%d,');
        canvas_str = canvas_str(1:end-1);
        canvas_str = canvas_str(~isspace(canvas_str));
        cmd_str = cmd_str + " --canvas_size=" + canvas_str;
    end

    if isfield(sim_configs, 'fov')
        fov = sim_configs.fov;
        cmd_str = cmd_str + " --fov=" + num2str(fov);
    end

    if isfield(sim_configs, 'robot_color')
        robot_color = sim_configs.robot_color;
        robot_color_str = num2str(robot_color, '%.5f,');
        robot_color_str = robot_color_str(1:end-1);
        robot_color_str = robot_color_str(~isspace(robot_color_str));
        cmd_str = cmd_str + " --color=" + robot_color_str;
    end

    if isfield(sim_configs, 'env_color')
        env_color = sim_configs.env_color;
        env_color_str = num2str(env_color, '%.5f,');
        env_color_str = env_color_str(1:end-1);
        env_color_str = env_color_str(~isspace(env_color_str));
        cmd_str = cmd_str + " --env_color=" + env_color_str;
    end

    if isfield(sim_configs, 'camera')
        camera = sim_configs.camera;
        camera_str = num2str(camera, '%.2f,');
        camera_str = camera_str(1:end-1);
        camera_str = camera_str(~isspace(camera_str));
        cmd_str = cmd_str + " --camera=" + camera_str;
    end

    if isfield(sim_configs, 'light')
        light = sim_configs.light;
        light_str = num2str(light, '%.2f,');
        light_str = light_str(1:end-1);
        light_str = light_str(~isspace(light_str));
        cmd_str = cmd_str + " --light=" + light_str;
    end

    % Run simulation
    dv = current_robot(12:end);
    dv = dv(~isnan(dv));
    time_out = 30; % TODO: should read from sim_params.xml
    dv_str = num2str(dv, '%.5f,');
    dv_str = dv_str(1:end-1);
    dv_str = dv_str(~isspace(dv_str));
    if sim_configs.async
        cmd_str = "start ";
    end
    cmd_str = cmd_str + ...
              " --robot_type mesh " + ...
              " --sim_param " + fullfile(result.path, app.sim_params_filename) + ...
              " --sim_time " + num2str(time_out) + ...
              " --design_vector=" + dv_str;
    if isfield(sim_configs, 'record_frame') && sim_configs.record_frame
        cmd_str = cmd_str + ...
                  " --frame_output_name=" + sim_configs.frame_output_name + ...
                  " --frame_interval=" + num2str(20); % 10 Hz
    end
    [~, cmdout] = system(cmd_str, '-echo');
    fitness_cell = regexp(cmdout, 'The fitness of this robot: (-?\d*\.\d*)', 'tokens');
    robot_info.best_fitness_visual = str2double(fitness_cell{1});
end
