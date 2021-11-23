function open_folder(app)
    if length(app.results) == 0 || length(app.ResultsListBox.Value) == 0
        return
    end
    result_path = app.results{app.ResultsListBox.Value{1}}.path;
    % TODO: make it work on other systems as well
    winopen(result_path);
end
