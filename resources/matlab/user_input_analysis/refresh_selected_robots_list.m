function refresh_selected_robots_list(app)
% List all robots selected by the results_enabled matrix in the ListBox
% Display format: user_id-env-ver-fitness
    % TODO: probably can initialize the user_inputs_selected matrix to the right size
    app.user_inputs_selected = [];
    app.SelectedRobotsListBox.Items = {};
    app.SelectedRobotsListBox.ItemsData = [];

    for i = 1 : size(app.results_enabled, 1) % user_id
        for j = 1 : size(app.results_enabled, 2) % env_id
            result = app.results{i};
            if app.results_enabled(i,j) == 1
                % get the internal fitness ranking and also remove the robots with the same fitness
                % TODO: better way to tell if the robot is a duplicate?
                % [~, sort_order] = sort(result.fitness(j, :), 'descend'); % descending order of fitness
                [~, sort_order, ~] = unique(result.fitness(j, :)); % ascending order of fitness
                sort_order = flip(sort_order);

                rank = 1;
                for ik = 1 : length(sort_order) % ver id
                    k = sort_order(ik);
                    app.user_inputs_selected(end+1, :) = [result.internal_id, j, k, result.fitness(j, k), rank];

                    tmp_str = [result.user_id, '-'];
                    % TODO: hard coded env here
                    if j == 1
                        tmp_str = [tmp_str, 'g'];
                    elseif j == 2
                        tmp_str = [tmp_str, 's'];
                    elseif j == 3
                        tmp_str = [tmp_str, 'v'];
                    end

                    tmp_str = [tmp_str, '-', num2str(k), '-(' num2str(result.fitness(j,k)), ')(', num2str(rank), ')'];

                    app.SelectedRobotsListBox.Items{end+1} = tmp_str;
                    app.SelectedRobotsListBox.ItemsData(end+1) = size(app.user_inputs_selected, 1);
                    rank = rank + 1;
                end
            end
        end
    end

    sort_selected_robots_list_by_fitness(app);
end
