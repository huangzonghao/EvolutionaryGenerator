function refresh_selected_robots_list(app)
% List all robots selected by the results_enabled matrix in the ListBox
% Display format: user_id-env-ver-fitness
    app.user_inputs_selected = [];
    app.SelectedRobotsListBox.Items = {};
    app.SelectedRobotsListBox.ItemsData = [];

    for i = 1 : size(app.results_enabled, 1) % user_id
        for j = 1 : size(app.results_enabled, 2) % env_id
            result = app.results{i};
            if app.results_enabled(i,j) == 1
                for k = 1 : length(result.fitness(j,:))
                    app.user_inputs_selected(end+1, :) = [result.internal_id, j, k];

                    tmp_str = [result.user_id, '-'];
                    % TODO: hard coded env here
                    if j == 1
                        tmp_str = [tmp_str, 'g'];
                    elseif j == 2
                        tmp_str = [tmp_str, 's'];
                    elseif j == 3
                        tmp_str = [tmp_str, 'v'];
                    end

                    tmp_str = [tmp_str, '-', num2str(k), '-' num2str(result.fitness(j,k))];

                    app.SelectedRobotsListBox.Items{end+1} = tmp_str;
                    app.SelectedRobotsListBox.ItemsData(end+1) = size(app.user_inputs_selected, 1);
                end
            end
        end
    end
end
