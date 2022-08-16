function load_virtual_results(app)
    virtual_results_file = fullfile(app.result_group_path, 'virtual_results.mat');
    if ~isfile(virtual_results_file)
        app.virtual_results = {};
    else
        virtual_results_load = load(virtual_results_file);
        app.virtual_results = virtual_results_load.virtual_results;
    end

    app.VirtualResultsListBox.Items = {};
    for i = 1 : length(app.virtual_results)
        app.VirtualResultsListBox.Items{i} = [app.virtual_results{i}.name, '(', num2str(app.virtual_results{i}.num_results), ')'];
        app.VirtualResultsListBox.ItemsData(i) = i;
    end
end
