function add_target_to_compare(app, adding_virtual)
    if ~adding_virtual % raw results
        for i = 1 : length(app.ResultsListBox.Value)
            target.isgroup = false;
            target.id = app.ResultsListBox.Value{i};
            target.name = app.results{target.id}.name;
            app.targets_to_compare{end + 1} = target;
            app.CompareListBox.Items{end + 1} = target.name;
            app.CompareListBox.ItemsData(end + 1) = length(app.targets_to_compare);
        end
    else % virtual results
        for i = 1 : length(app.VirtualResultsListBox.Value)
            target.isgroup = true;
            target.id = app.VirtualResultsListBox.Value(i);
            target.name = app.virtual_results{target.id}.name;
            app.targets_to_compare{end + 1} = target;
            app.CompareListBox.Items{end + 1} = target.name;
            app.CompareListBox.ItemsData(end + 1) = length(app.targets_to_compare);
        end
    end
end
