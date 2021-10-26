function run_simulation(app)
    % Note here in CG, x goes from left to right and y goes from
    % top to bottom -- x is column index, y is row index
    idx = robot_idx_in_archive(app, str2double(app.RobotIDYField.Value), str2double(app.RobotIDXField.Value));
    if (idx == -1)
        app.RobotInfoLabel.Text = "Error: Cell (" + app.RobotIDXField.Value + ", " + app.RobotIDYField.Value + ") of Gen " + num2str(app.current_gen) + " empty";
    end
    app.RobotInfoLabel.Text = "Fitness: " + num2str(app.current_gen_archive(idx, 4));
    dv = app.current_gen_archive(idx, 5:end);
    dv = dv(~isnan(dv));
    cmd_str = fullfile(app.evogen_exe_path, app.simulator_name) + " mesh " + ...
              fullfile(app.result_path, app.sim_params_filename) + " " + ...
              num2str(dv);
    system(cmd_str);
end
