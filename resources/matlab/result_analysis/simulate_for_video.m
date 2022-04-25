function simulate_for_video(app)
    if length(app.targets_to_compare) == 0 || app.targets_to_compare{1}.isgroup
        msgbox('Add a single result to comparison target to run video simulation');
        return
    end
    current_gen = app.VideoGenIDField.Value;
    if current_gen > 2000 || current_gen < 0
        msgbox('Enter a gen number in range [0, 2000]');
        return
    end

    result = load_target_result(app, false, app.targets_to_compare{1}.id);
    robot_info = {};
    robot_info.result_name = result.name;
    robot_info.archive_gen = current_gen;

    % now load the best robot of that current_gen
    current_gen_archive = result.archive{current_gen + 1};
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

    % Dump files
    disp(sprintf("simulating robot of %s, gen %d, id %d, fitness %d, fid1 %d, fid2 %d", robot_info.result_name, robot_info.gen, robot_info.id, robot_info.fitness, robot_info.fid1, robot_info.fid2));
    filename = strcat('./', robot_info.result_name, '_', num2str(robot_info.archive_gen), '_best_robot_info.json');
    new_file_spec = fopen(filename, "wt");
    fprintf(new_file_spec, jsonencode(robot_info, 'PrettyPrint', true));
    fclose(new_file_spec);

    % Run simulation
    dv = current_robot(12:end);
    dv = dv(~isnan(dv));
    time_out = 30; % TODO: should read from sim_params.xml
    dv_str = num2str(dv, '%.5f,');
    dv_str = dv_str(1:end-1);
    dv_str = dv_str(~isspace(dv_str));
    canvas_str = num2str([960, 360], '%d,');
    canvas_str = canvas_str(1:end-1);
    canvas_str = canvas_str(~isspace(canvas_str));
    color_str = num2str([0.8, 0.8, 0.8], '%.5f,');
    color_str = color_str(1:end-1);
    color_str = color_str(~isspace(color_str));
    camera_str = num2str([0, -12, 10, 0, 0, 0], '%.2f,');
    camera_str = camera_str(1:end-1);
    camera_str = camera_str(~isspace(camera_str));
    cmd_str = "start " + fullfile(app.evogen_exe_path, app.simulator_name) + ...
              " --robot_type mesh " + ...
              " --sim_param " + fullfile(result.path, app.sim_params_filename) + ...
              " --sim_time " + num2str(time_out) + ...
              " --color=" + color_str + ...
              " --camera=" + camera_str + ...
              " --canvas_size=" + canvas_str + ...
              " --design_vector=" + dv_str;
    system(cmd_str);
end
