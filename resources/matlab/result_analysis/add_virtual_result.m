function add_virtual_result(app)
% Virtual result is the grouping of several actual result.
% Fields of virtual result:
%     isgroup: true.
%     name: name of the virtual result.
%     ids: the list of id of the actual results contained by this virtual result.
%     num_results: total number of actual results contained in this virtual result,
%         equal to the length of ids.
    if isempty(app.VirtualResultNameField.Value)
        msgbox("Specify a group name when adding a group");
        return
    end

    new_virtual_result.isgroup = true;
    new_virtual_result.name = app.VirtualResultNameField.Value;
    new_virtual_result.ids = cell2mat(app.ResultsListBox.Value);
    new_virtual_result.num_results = length(app.ResultsListBox.Value);

    app.virtual_results{end+1} = new_virtual_result;
    virtual_results = app.virtual_results;
    save(fullfile(app.result_group_path, 'virtual_results.mat'), 'virtual_results', '-v7.3');
    load_virtual_results(app);
end
