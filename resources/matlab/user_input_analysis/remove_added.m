function remove_added(app)
    idx_to_remove = app.AddedRobotsListBox.Value;
    if isempty(idx_to_remove)
        return
    end
    for i = 1 : length(idx_to_remove)
        disp(['removing ', num2str(idx_to_remove(i))]);
        app.AddedRobotsListBox.Items(app.AddedRobotsListBox.ItemsData == idx_to_remove(i)) = [];
    end
end
