function open_folder(app)
    if length(app.result_paths) == 0 || length(app.ResultsListBox.Value) == 0
        return
    end
    result_path = app.result_paths(app.ResultsListBox.Value{1});
    % TODO: make it work on other systems as well
    winopen(result_path);
end
