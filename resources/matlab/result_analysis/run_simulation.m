function run_simulation(app)
    % Note here in CG, x goes from left to right and y goes from
    % top to bottom -- x is column index, y is row index

    result = app.current_result;

    % Note the XY has been flipped already in gui layout
    fid_x = str2double(app.RobotIDXField.Value);
    fid_y = str2double(app.RobotIDYField.Value);
    if fid_x <= 0 || fid_x > result.evo_params.griddim_0 || fid_y <=0 || fid_y > result.evo_params.griddim_1
        msgbox(sprintf("Error: Invalid robot coord (%d, %d)", fid_y, fid_x));
    end
    id_in_archive = app.archive_ids(fid_x, fid_y);
    if (id_in_archive == 0)
        msgbox("Error: Cell (" + app.RobotIDXField.Value + ", " + app.RobotIDYField.Value + ") of Gen " + num2str(app.current_gen) + " empty");
        return
    end

    current_gen = app.current_gen;
    current_gen_archive = result.archive{current_gen + 1};
    gen_id = current_gen_archive(id_in_archive, 1);
    id = current_gen_archive(id_in_archive, 2);
    robot_file_buffer = readmatrix(fullfile(result.path, strcat('/robots/', num2str(gen_id), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
    dv = robot_file_buffer(robot_file_buffer(:, 2)==id, 12:end);
    dv = dv(~isnan(dv));
    time_out = app.SimTimeEditField.Value;
    if time_out < 0
        msgbox("Error: negative simulation time");
    end
    cmd_str = 'start' + fullfile(app.evogen_exe_path, app.simulator_name) + " mesh " + ...
              fullfile(result.path, app.sim_params_filename) + " " + num2str(time_out) + " " + ...
              num2str(dv);
    system(cmd_str);
end
