function plot_archive(app)
    if length(app.results) == 0
        disp('plot_archive Error: no result loaded');
        return
    end

    if sum(app.results_enabled(:)) == 0
        return
    end

    open_plot(app);

    ref = app.main_ref_plot;
    app.archive_map(:) = 0;
    app.map_stat(:) = 0;

    for i = 1 : size(app.results_enabled, 1) % user_id
        for j = 1 : size(app.results_enabled, 2) % env_id
            if app.results_enabled(i,j) == 1
                add_to_archive(app, app.results{i}.feature(j,:,:), app.results{i}.fitness(j,:), j);
            end
        end
    end

    ref.map_surf.select();
    surf(app.archive_map);
    title('Archive Map');
    xlabel(app.default_feature_description(2)); % x, y flipped in plot
    ylabel(app.default_feature_description(1));
    zlabel('Fitness');

    ref.map_heat.select();
    % TODO: too dirty -- somehow heatmap destroies the original axis
    ref.heat_axes.map_heat = heatmap(app.archive_map);
    title('Archive Map');
    xlabel(app.default_feature_description(2)); % x, y flipped in plot
    ylabel(app.default_feature_description(1));

    % bar3(app.MapStatViewerAxes, app.map_stat, 1, 'b');
    ref.stat_bar.select();
    app.stacked_bar3(ref.stat_bar.axis, app.map_stat);
    title('Updates per Bin');
    xlabel(app.default_feature_description(2)); % x, y flipped in plot
    ylabel(app.default_feature_description(1));
    zlabel('Number of robots');

    ref.stat_heat.select();
    % TODO: too dirty -- somehow heatmap destroies the original axis
    ref.heat_axes.map_stat = heatmap(sum(app.map_stat, 3));
    title('Updates per Bin');
    xlabel(app.default_feature_description(2)); % x, y flipped in plot
    ylabel(app.default_feature_description(1));

    app.main_ref_plot = ref;
    update_plots_range(app, min(app.archive_map(:)), max(app.archive_map(:)));
end
