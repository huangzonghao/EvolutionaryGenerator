function refresh_added_robots_list(app)
% Add the selected robots from the selected_list to added_list
% Display format: user_id-env-ver-fitness
    idxs = app.SelectedRobotsListBox.Value;
    if isempty(idxs)
        return
    end

    for i = 1 : length(idxs)
        app.AddedRobotsListBox.Items{end+1} = app.SelectedRobotsListBox.Items{idxs(i)};
        app.AddedRobotsListBox.ItemsData(end+1) = idxs(i);
    end

    app.TotalAddedCountLabel.Text = ['Total: ', num2str(length(app.AddedRobotsListBox.Items))];
end
