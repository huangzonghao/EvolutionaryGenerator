function remove_added(app)
    idx_to_remove = app.AddedRobotsListBox.Value;
    if isempty(idx_to_remove)
        return
    end
    app.AddedRobotsListBox.Items(idx_to_remove) = [];
    app.user_inputs_added(idx_to_remove, :) = [];

    app.TotalAddedCountLabel.Text = ['Total: ', num2str(length(app.AddedRobotsListBox.Items))];
end
