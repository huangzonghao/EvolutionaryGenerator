function clear_added_robots_list(app)
    app.AddedRobotsListBox.Items = {};
    app.AddedRobotsListBox.ItemsData = [];
    app.user_inputs_added = [];
    app.TotalAddedCountLabel.Text = ['Total: ', num2str(length(app.AddedRobotsListBox.Items))];
end
