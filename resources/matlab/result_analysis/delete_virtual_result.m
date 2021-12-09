function delete_virtual_result(app)
    if isempty(app.VirtualResultsListBox.Value)
        return
    end

    app.virtual_results(app.VirtualResultsListBox.Value) = [];
    virtual_results = app.virtual_results;
    save(fullfile(app.result_group_path, 'virtual_results.mat'), 'virtual_results', '-v7.3');
    load_virtual_results(app);
end
