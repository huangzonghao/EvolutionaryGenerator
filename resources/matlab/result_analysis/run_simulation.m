function run_simulation(app)
    % Note here in CG, x goes from left to right and y goes from
    % top to bottom -- x is column index, y is row index

    id_in_archive = app.archive_ids(str2double(app.RobotIDYField.Value), str2double(app.RobotIDXField.Value));
    if (id_in_archive == 0)
        app.RobotInfoLabel.Text = "Error: Cell (" + app.RobotIDXField.Value + ", " + app.RobotIDYField.Value + ") of Gen " + num2str(app.current_gen) + " empty";
        return
    end

    app.RobotInfoLabel.Text = "Fitness: " + num2str(app.current_gen_archive(id_in_archive, 5));
    gen_id = app.current_gen_archive(id_in_archive, 1);
    id = app.current_gen_archive(id_in_archive, 2);
    if app.robots_gen ~= gen_id
        app.robots_buffer = readmatrix(fullfile(app.result_path, strcat('/robots/', num2str(gen_id), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
        app.robots_gen = gen_id;
    end
    robot_data = app.robots_buffer(app.robots_buffer(:, 2)==id, :);
    dv = robot_data(12:end);
    dv = dv(~isnan(dv));
    cmd_str = fullfile(app.evogen_exe_path, app.simulator_name) + " mesh " + ...
              fullfile(app.result_path, app.sim_params_filename) + " " + ...
              num2str(dv);
    system(cmd_str);
end
