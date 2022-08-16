function sim_report = simulate_robot(app, sim_configs)
% Unified interface to simulate a robot from results
% This function would first try to simulate from raw text based dump of robots
% from training. If the text dump doesn't exist, it will try to simulate with
% the post-generated mat dump.
% sim_configs:
%     result_id
%     gen_id: use c++ numbering, starts from 0
%     robot_id: use c++ numbering, starts from 0
%     other simulation params

    sim_report = {};
    sim_report.done = false;
    % First try to gather required information for simulation
    result = load_target_result(app, false, sim_configs.result_id);
    if isfolder(fullfile(result.path, '/robots'))
        robot_file_buffer = readmatrix(fullfile(result.path, strcat('/robots/', num2str(sim_configs.gen_id), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
        current_robot = robot_file_buffer(robot_file_buffer(:, 2)==sim_configs.robot_id, :);
        dv = current_robot(12:end);
    elseif isfile(fullfile(result.path, '/robots_dump.mat'));
        if isfield(result, 'robots_dump')
            robots_dump = result.robots_dump;
        else
            robots_dump_container = load(fullfile(result.path, 'robots_dump.mat'));
            app.results{result.id}.result.robots_dump = robots_dump_container.robots_dump;
            robots_dump = robots_dump_container.robots_dump;
        end
        dv = robots_dump{sim_configs.gen_id + 1}{sim_configs.robot_id + 1};
    else
        disp(['Simulation Error: cannot find robot information in ', result.path]);
        return
    end
    dv = dv(~isnan(dv));
    dv_str = num2str(dv, '%.5f,');
    dv_str = dv_str(1:end-1);
    dv_str = dv_str(~isspace(dv_str));

    cmd_str = fullfile(app.evogen_exe_path, app.simulator_name);

    if isfield(sim_configs, 'async') && sim_configs.async
        cmd_str = "start " + cmd_str;
    else
        sim_configs.async = false;
    end

    if isfield(sim_configs, 'mode')
        cmd_str = cmd_str + " --mode=" + sim_configs.mode;
    end

    if isfield(sim_configs, 'canvas_size')
        canvas_str = num2str(sim_configs.canvas_size, '%d,');
        canvas_str = canvas_str(1:end-1);
        canvas_str = canvas_str(~isspace(canvas_str));
        cmd_str = cmd_str + " --canvas_size=" + canvas_str;
    end

    if isfield(sim_configs, 'fov')
        cmd_str = cmd_str + " --fov=" + num2str(sim_configs.fov);
    end

    if isfield(sim_configs, 'robot_color')
        robot_color_str = num2str(sim_configs.robot_color, '%.5f,');
        robot_color_str = robot_color_str(1:end-1);
        robot_color_str = robot_color_str(~isspace(robot_color_str));
        cmd_str = cmd_str + " --color=" + robot_color_str;
    end

    if isfield(sim_configs, 'env_color')
        env_color_str = num2str(sim_configs.env_color, '%.5f,');
        env_color_str = env_color_str(1:end-1);
        env_color_str = env_color_str(~isspace(env_color_str));
        cmd_str = cmd_str + " --env_color=" + env_color_str;
    end

    if isfield(sim_configs, 'camera')
        camera_str = num2str(sim_configs.camera, '%.2f,');
        camera_str = camera_str(1:end-1);
        camera_str = camera_str(~isspace(camera_str));
        cmd_str = cmd_str + " --camera=" + camera_str;
    end

    if isfield(sim_configs, 'light')
        light_str = num2str(sim_configs.light, '%.2f,');
        light_str = light_str(1:end-1);
        light_str = light_str(~isspace(light_str));
        cmd_str = cmd_str + " --light=" + light_str;
    end

    if isfield(sim_configs, 'time_out')
        cmd_str = cmd_str + " --sim_time=" + num2str(sim_configs.time_out);
    end

    if isfield(sim_configs, 'record_frame') && sim_configs.record_frame
        cmd_str = cmd_str + ...
                  " --frame_output_name=" + sim_configs.frame_output_name + ...
                  " --frame_interval=" + num2str(20); % 10 Hz
    end

    cmd_str = cmd_str + ...
              " --robot_type mesh " + ...
              " --sim_param " + fullfile(result.path, app.sim_params_filename) + ...
              " --design_vector=" + dv_str;

    [~, cmdout] = system(cmd_str, '-echo');

    % Generate simulation report
    if ~sim_configs.async
        fitness_cell = regexp(cmdout, 'The fitness of this robot: (-?\d*\.\d*)', 'tokens');
        if ~isempty(fitness_cell)
            sim_report.fitness = str2double(fitness_cell{1});
            sim_report.done = true;
        end
    end
end
