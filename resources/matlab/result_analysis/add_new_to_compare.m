function add_new_to_compare(app, adding_group)
    if ~adding_group
        for i = 1 : length(app.ResultsListBox.Value)
            tmp_result_path = app.results{app.ResultsListBox.Value{i}}.path;
            [~, result_name, ~] = fileparts(tmp_result_path);
            % return if the result has already been added
            for i = 1 : length(app.results_to_compare)
                if ~app.results_to_compare{i}.isgroup && app.results_to_compare{i}.name == result_name
                    continue
                end
            end
            new_result.isgroup = false;
            new_result.name = result_name;
            new_result.full_path = tmp_result_path;

            [nickname, nickname_loaded] = load_nickname(tmp_result_path);
            if nickname_loaded
                app.CompareListBox.Items{end + 1} = nickname;
                new_result.name = nickname;
            else
                app.CompareListBox.Items{end + 1} = convertStringsToChars(result_name);
            end

            app.results_to_compare{end + 1} = new_result;
            app.CompareListBox.ItemsData(end + 1) = length(app.results_to_compare);
        end
    else
        if isempty(app.GroupNameField.Value)
            msgbox("Specify a group name when adding a group");
            return
        end

        new_group.isgroup = true;;
        new_group.name = app.GroupNameField.Value;
        new_group.result_names = string.empty;
        new_group.result_full_paths = string.empty;

        for i = 1 : length(app.ResultsListBox.Value)
            tmp_result_path = app.results{app.ResultsListBox.Value{i}}.path;
            [~, result_name, ~] = fileparts(tmp_result_path);
            new_group.result_names(end + 1) = result_name;
            new_group.result_full_paths(end + 1) = tmp_result_path;
        end
        app.CompareListBox.Items{end + 1} = new_group.name;
        app.results_to_compare{end + 1} = new_group;
        app.CompareListBox.ItemsData(end + 1) = length(app.results_to_compare);
    end
end
