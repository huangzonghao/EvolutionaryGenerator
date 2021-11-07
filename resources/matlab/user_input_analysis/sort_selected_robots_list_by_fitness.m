function sort_selected_robots_list_by_fitness(app)
    [~, sort_order] = sort(app.user_inputs_selected(:, 4) , 'descend'); % descending order of fitness
    sort_order = sort_order';
    app.user_inputs_selected = app.user_inputs_selected(sort_order, :); % sort the internal storage so that we support repetitive sortings
    app.SelectedRobotsListBox.Items = app.SelectedRobotsListBox.Items(sort_order);
end
