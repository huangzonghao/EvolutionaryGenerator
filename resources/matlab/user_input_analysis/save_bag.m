function save_bag(app)
    idxs = app.AddedRobotsListBox.ItemsData;
    if length(idxs) == 0
        return
    end
    for i = 1 : length(idxs)
        robot_info = app.user_inputs_selected(idxs(i), :);
        result = app.results{robot_info(1)};
        tmp_obj.user_id = result.user_id;
        tmp_obj.env = app.default_env_order(robot_info(2));
        tmp_obj.gene = result.gene{robot_info(2), robot_info(3)};
        jsobj.(['x', num2str(i)]) = tmp_obj;
    end

    % Add timestamp and comments
    jsobj.timestamp = datestr(now,'yyyy-mm-dd HH:MM:SS');
    jsobj.comments = string(app.CommentTextArea.Value);
    jsobj.total_count = length(idxs);

    dirname = fullfile(app.user_input_dir, 'Bags');
    if ~exist(dirname, 'dir')
        mkdir(dirname);
    end
    filename = strcat(fullfile(dirname, strcat('Bag_', app.OutputBagNameField.Value)), '.json');
    new_file_spec = fopen(filename, "wt");
    fprintf(new_file_spec, jsonencode(jsobj));
    fclose(new_file_spec);
    msgbox(['Bag file saved to ', filename]);
end
