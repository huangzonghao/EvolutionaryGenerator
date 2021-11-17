function plot_archive_map(app)
    app.archive_map = zeros(app.evo_params.griddim_0, app.evo_params.griddim_1);
    app.archive_ids = zeros(app.evo_params.griddim_0, app.evo_params.griddim_1);
    x = app.current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
    y = app.current_gen_archive(:, 4) + 1;
    fitness = app.current_gen_archive(:, 5);
    app.archive_map(sub2ind(size(app.archive_map), x, y)) = fitness;
    app.archive_ids(sub2ind(size(app.archive_map), x, y)) = [1:length(fitness)];
    surf(app.gen_plot.archive_surf_ax, app.archive_map);
    xlabel(app.gen_plot.archive_surf_ax, app.evo_params.feature_description2); % x, y flipped in plot
    ylabel(app.gen_plot.archive_surf_ax, app.evo_params.feature_description1);
    % app.GenInfoLabel.Text =...
        % sprintf('Gen: %d/%d, Archive size: %d/%d',...
        % app.current_gen, app.evo_params.nb_gen, size(x, 1),...
        % app.evo_params.griddim_0 * app.evo_params.griddim_1);

    % Note the swapping of x, y here
    app.RobotIDXField.Value = num2str(y(1));
    app.RobotIDYField.Value = num2str(x(1));
end
