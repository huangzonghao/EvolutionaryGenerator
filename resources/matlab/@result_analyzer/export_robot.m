function export_robot(app)
    if isempty(app.current_result)
        return
    end

    result = app.current_result;

    % Note the XY has been flipped already in gui layout
    fid_x = str2double(app.RobotIDXField.Value);
    fid_y = str2double(app.RobotIDYField.Value);
    if fid_x <= 0 || fid_x > result.evo_params.grid_dim(1) || fid_y <=0 || fid_y > result.evo_params.grid_dim(2)
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
    fitness = current_gen_archive(id_in_archive, 5);
    robot_file_buffer = readmatrix(fullfile(result.path, strcat('/robots/', num2str(gen_id), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
    dv = robot_file_buffer(robot_file_buffer(:, 2)==id, 12:end);
    dv = dv(~isnan(dv));
    time_out = app.SimTimeEditField.Value;
    if time_out < 0
        msgbox("Error: negative simulation time");
    end

    [~, group_basename, ~] = fileparts(app.result_group_path);
    export_dir = fullfile(app.result_group_path, 'exported_robots');
    if ~isdir(export_dir)
        mkdir(export_dir);
    end

    jsobj.type = "Exported";
    jsobj.result_group = group_basename;
    jsobj.result_name = result.name;
    jsobj.gen = current_gen;
    jsobj.feature_id = [fid_x, fid_y];
    jsobj.fitness = fitness;
    jsobj.gene = dv;

    export_filename = fullfile(export_dir, [result.name, '_gen_', num2str(current_gen), '_(', num2str(fid_y), '-', num2str(fid_x), ')_', num2str(fitness), '.json']);
    new_file_spec = fopen(export_filename, "wt");
    fprintf(new_file_spec, jsonencode(jsobj, 'PrettyPrint', true));
    fclose(new_file_spec);

    msgbox(['Robot exported to ', export_filename]);
end
