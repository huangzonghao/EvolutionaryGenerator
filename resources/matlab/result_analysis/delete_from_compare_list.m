function delete_from_compare_list(app, do_remove_all)
    if do_remove_all
        app.targets_to_compare = {};
        app.CompareListBox.Items = {};
        return
    end

    if isempty(app.CompareListBox.Value)
        return
    end

    app.targets_to_compare(app.CompareListBox.Value) = [];
    app.CompareListBox.Items(app.CompareListBox.Value) = [];
end
