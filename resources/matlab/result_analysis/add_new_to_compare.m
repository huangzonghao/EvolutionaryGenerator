function add_new_to_compare(app)
    tmp_result_path = uigetdir(app.evogen_results_path, 'EvoGen Result Dir');
    figure(app.MainFigure);
    if (tmp_result_path == 0) % User pressed cancel button
        return
    end
    [~, result_name, ~] = fileparts(tmp_result_path);
    % return if the result has already been aded
    if sum(app.result_to_compare == result_name) > 0
        return
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
