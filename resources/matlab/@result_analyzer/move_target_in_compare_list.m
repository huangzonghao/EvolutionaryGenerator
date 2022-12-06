function move_target_in_compare_list(app, move_up)
    if length(app.CompareListBox.Value) == 0
        return
    end
    selected_idx = app.CompareListBox.Value(1);
    if move_up
        if selected_idx == 1
            return
        end
        target_idx = selected_idx - 1;
    else
        if selected_idx == length(app.targets_to_compare)
            return
        end
        target_idx = selected_idx + 1;
    end

    tmp_target = app.targets_to_compare{target_idx};
    app.targets_to_compare{target_idx} = app.targets_to_compare{selected_idx};
    app.targets_to_compare{selected_idx} = tmp_target;

    app.CompareListBox.Items{target_idx} = app.targets_to_compare{target_idx}.name;
    app.CompareListBox.Items{selected_idx} = app.targets_to_compare{selected_idx}.name;
    app.CompareListBox.ItemsData = 1 : length(app.CompareListBox.Items);
    app.CompareListBox.Value = target_idx;
end

