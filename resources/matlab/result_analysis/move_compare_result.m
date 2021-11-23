function move_compare_result(app, move_up)
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
        if selected_idx == length(app.results_to_compare)
            return
        end
        target_idx = selected_idx + 1;
    end

    tmp_result = app.results_to_compare{target_idx};
    app.results_to_compare{target_idx} = app.results_to_compare{selected_idx};
    app.results_to_compare{selected_idx} = tmp_result;

    app.CompareListBox.Items{target_idx} = app.results_to_compare{target_idx}.name;
    app.CompareListBox.Items{selected_idx} = app.results_to_compare{selected_idx}.name;
    app.CompareListBox.Value = target_idx;
end
