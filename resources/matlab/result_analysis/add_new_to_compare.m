function add_new_to_compare(app)
    for i = 1 : length(app.ResultsListBox.Value)
        tmp_result_path = app.result_paths(app.ResultsListBox.Value{i});
        [~, result_name, ~] = fileparts(tmp_result_path);
        % return if the result has already been added
        if sum(app.result_to_compare == result_name) > 0
            continue
        end
        app.result_to_compare(end + 1) = result_name;

        [nickname, nickname_loaded] = load_nickname(tmp_result_path);
        if nickname_loaded
            app.CompareListBox.Items{end + 1} = nickname;
        else
            app.CompareListBox.Items{end + 1} = result_name;
        end
        app.CompareListBox.ItemsData(end + 1) = length(app.result_to_compare);
    end
end
