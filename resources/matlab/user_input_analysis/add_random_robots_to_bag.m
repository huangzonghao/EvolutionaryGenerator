function add_random_robots_to_bag(app)
    % a hard coded length based on the current implementation of the algorithm
    max_gene_length = 53;

    num = str2double(app.NumRandomField.Value);
    if num == 0
        return
    end

    new_random_robot = rand(num, max_gene_length);
    num_existing_random_robot = size(app.random_robots, 1);
    app.random_robots = [app.random_robots; new_random_robot];
    for i = num_existing_random_robot + 1 : num_existing_random_robot + num
        app.AddedRobotsListBox.Items{end+1} = strcat('random-', num2str(i));
        app.user_inputs_added(end+1, :) = [-1, 0, i, -Inf, 0];
        app.AddedRobotsListBox.ItemsData(end+1) = size(app.user_inputs_added, 1);

    end

    app.TotalAddedCountLabel.Text = ['Total: ', num2str(length(app.AddedRobotsListBox.Items))];
end

