function save_nickname(app)
    if isempty(app.NickNameField.Value)
        return
    end
    for i = 1 : length(app.ResultsListBox.Value)
        result_path = app.results(app.ResultsListBox.Value{i}).path;
        fid = fopen(fullfile(result_path, 'name.txt'), 'wt');
        fprintf(fid, app.NickNameField.Value);
        fclose(fid);
    end
    app.NickNameField.Value = string.empty;
    refresh_result_list(app);
end
