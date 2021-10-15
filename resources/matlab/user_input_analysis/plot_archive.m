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

    surf(app.MapViewerAxes, app.archive_map);
    title(app.MapViewerAxes, 'Archive Map');
    xlabel(app.MapViewerAxes, app.default_feature_description(2)); % x, y flipped in plot
    ylabel(app.MapViewerAxes, app.default_feature_description(1));
    zlabel(app.MapViewerAxes, 'Fitness');

    % bar3(app.MapStatViewerAxes, app.map_stat, 1, 'b');
    stacked_bar3(app.MapStatViewerAxes, app.map_stat);
    title(app.MapStatViewerAxes, 'Updates per Bin');
    xlabel(app.MapStatViewerAxes, app.default_feature_description(2)); % x, y flipped in plot
    ylabel(app.MapStatViewerAxes, app.default_feature_description(1));
    zlabel(app.MapStatViewerAxes, 'Number of robots');
end
