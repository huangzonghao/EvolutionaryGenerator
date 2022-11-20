function sort_added_robots_list_by_fitness(app)
    [~, sort_order] = sort(app.user_inputs_added(:, 4) , 'descend'); % descending order of fitness
    sort_order = sort_order';
    app.user_inputs_added = app.user_inputs_added(sort_order, :); % sort the internal storage so that we support repetitive sortings
    app.AddedRobotsListBox.Items = app.AddedRobotsListBox.Items(sort_order);
end
