function save_bag(app)
    if size(app.user_inputs_added, 1) == 0
        return
    end
    if app.OutputBagNameField.Value == ""
        msgbox("Specify a bag name");
        return
    end
    for i = 1 : size(app.user_inputs_added, 1)
        robot_info = app.user_inputs_added(i, :);
        if robot_info(1) == -1
            % random robot
            tmp_obj.user_id = "random";
            tmp_obj.env = "N/A";
            tmp_obj.ver = num2str(robot_info(3));
            tmp_obj.gene = app.random_robots(robot_info(3), :);
            tmp_obj.fitness_reference = robot_info(4);
        else
            result = app.results{robot_info(1)};
            tmp_obj.user_id = result.user_id;
            tmp_obj.env = app.default_env_order(robot_info(2));
            tmp_obj.ver = robot_info(3);
            tmp_obj.gene = result.gene{robot_info(2), robot_info(3)};
            tmp_obj.fitness_reference = robot_info(4);
        end
        jsobj.(['x', num2str(i)]) = tmp_obj;
    end

    % Add timestamp and comments
    jsobj.timestamp = datestr(now,'yyyy-mm-dd HH:MM:SS');
    jsobj.comments = string(app.CommentTextArea.Value);
    jsobj.total_count = size(app.user_inputs_added, 1);

    dirname = fullfile(app.user_input_dir, 'Bags');
    if ~exist(dirname, 'dir')
        mkdir(dirname);
    end
    filename = strcat(fullfile(dirname, strcat('Bag_', app.OutputBagNameField.Value)), '.json');
    new_file_spec = fopen(filename, "wt");
    fprintf(new_file_spec, jsonencode(jsobj));
    fclose(new_file_spec);
    msgbox(['Bag file saved to ', filename]);
    app.OutputBagNameField.Value = "output_filename";
end
