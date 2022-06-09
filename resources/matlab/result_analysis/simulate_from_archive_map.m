function simulate_from_archive_map(app)
    % Note here in CG, x goes from left to right and y goes from
    % top to bottom -- x is column index, y is row index

    time_out = app.SimTimeEditField.Value;
    if time_out < 0
        msgbox("Error: negative simulation time");
        return
    end

    result = app.current_result;

    % Note the XY has been flipped already in gui layout
    fid_x = str2double(app.RobotIDXField.Value);
    fid_y = str2double(app.RobotIDYField.Value);
    if isnan(fid_x) || isnan(fid_y) || fid_x <= 0 || ...
       fid_x > result.evo_params.griddim_0 || fid_y <=0 || fid_y > result.evo_params.griddim_1
        msgbox(sprintf("Error: Invalid robot coord (%d, %d)", fid_y, fid_x));
        return
    end

    id_in_archive = app.archive_ids(fid_x, fid_y);
    if (id_in_archive == 0)
        msgbox("Error: Cell (" + app.RobotIDXField.Value + ", " + app.RobotIDYField.Value + ") of Gen " + num2str(app.current_gen) + " empty");
        return
    end

    current_gen = app.current_gen;
    current_gen_archive = result.archive{current_gen + 1};
    robot_gen = current_gen_archive(id_in_archive, 1);
    robot_id = current_gen_archive(id_in_archive, 2);

    sim_configs = video_simulation_configs(result.env);
    sim_configs.result_id = result.id;
    sim_configs.gen_id = robot_gen;
    sim_configs.robot_id = robot_id;
    sim_configs.time_out = time_out;
    sim_configs.robot_color = [1, 0.0, 0.0];
    % sim_configs.canvas_size = [960, 360];
    % sim_configs.camera = [0, -12, 10, 0, 0, 0];
    sim_configs.async = true;

    sim_report = simulate_robot(app, sim_configs);
end
