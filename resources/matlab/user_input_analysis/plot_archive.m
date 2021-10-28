function plot_archive(app)
    if length(app.results) == 0
        disp('plot_archive Error: no result loaded');
        return
    end

    app.archive_map(:) = 0;
    app.map_stat(:) = 0;

    for i = 1 : size(app.results_enabled, 1) % user_id
        for j = 1 : size(app.results_enabled, 2) % env_id
            if app.results_enabled(i,j) == 1
                add_to_archive(app, app.results{i}.feature(j,:,:), app.results{i}.fitness(j,:), j);
            end
        end
    end

    app.map_surf.select();
    surf(app.archive_map);
    title('Archive Map');
    xlabel(app.default_feature_description(2)); % x, y flipped in plot
    ylabel(app.default_feature_description(1));
    zlabel('Fitness');

    app.map_heat.select();
    heatmap(app.archive_map);
    title('Archive Map');
    xlabel(app.default_feature_description(2)); % x, y flipped in plot
    ylabel(app.default_feature_description(1));

    % bar3(app.MapStatViewerAxes, app.map_stat, 1, 'b');
    app.stat_bar.select();
    stacked_bar3(app.stat_bar.axis, app.map_stat);
    title('Updates per Bin');
    xlabel(app.default_feature_description(2)); % x, y flipped in plot
    ylabel(app.default_feature_description(1));
    zlabel('Number of robots');

    app.stat_heat.select();
    heatmap(sum(app.map_stat, 3));
    title('Updates per Bin');
    xlabel(app.default_feature_description(2)); % x, y flipped in plot
    ylabel(app.default_feature_description(1));
end
