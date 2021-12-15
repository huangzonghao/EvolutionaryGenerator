function add_virtual_result(app)
    if isempty(app.VirtualResultNameField.Value)
        msgbox("Specify a group name when adding a group");
        return
    end

    new_result.isgroup = true;
    new_result.name = app.VirtualResultNameField.Value;
    new_result.result_names = string.empty;
    new_result.result_full_paths = string.empty;
    new_result.num_results = length(app.ResultsListBox.Value);

    % TODO: virtual results should take advantage of the new result container as well
    for i = 1 : length(app.ResultsListBox.Value)
        tmp_result_path = app.results{app.ResultsListBox.Value{i}}.path;
        [~, result_name, ~] = fileparts(tmp_result_path);
        new_result.result_names(end + 1) = result_name;
        new_result.result_full_paths(end + 1) = tmp_result_path;
    end

    app.virtual_results{end+1} = new_result;
    virtual_results = app.virtual_results;
    save(fullfile(app.result_group_path, 'virtual_results.mat'), 'virtual_results', '-v7.3');
    load_virtual_results(app);
end
