function plot_heatmap(app)
    app.archive_map = zeros(app.evo_params.griddim_0, app.evo_params.griddim_1);
    x = app.current_gen_archive(:, 2);
    y = app.current_gen_archive(:, 3);
    fitness = app.current_gen_archive(:, 4);
    x = round(x * double(app.evo_params.griddim_0 - 1)) + 1;
    y = round(y * double(app.evo_params.griddim_1 - 1)) + 1;
    app.archive_map(sub2ind(size(app.archive_map), x, y)) = fitness;
    surf(app.MapViewerAxes, app.archive_map);
    xlabel(app.MapViewerAxes, app.evo_params.feature_description2); % x, y flipped in plot
    ylabel(app.MapViewerAxes, app.evo_params.feature_description1);
    app.GenInfoLabel.Text =...
        sprintf('Gen: %d/%d, Archive size: %d/%d',...
        app.current_gen, app.evo_params.nb_gen, size(x, 1),...
        app.evo_params.griddim_0 * app.evo_params.griddim_1);

    app.current_gen_x_idx = x;
    app.current_gen_y_idx = y;
    % Note the swapping of x, y here
    app.RobotIDXField.Value = num2str(y(1));
    app.RobotIDYField.Value = num2str(x(1));
    idx = robot_idx_in_archive(app, x(1), y(1));
    app.RobotInfoLabel.Text = "Fitness: " + num2str(app.current_gen_archive(idx, 4));
end
