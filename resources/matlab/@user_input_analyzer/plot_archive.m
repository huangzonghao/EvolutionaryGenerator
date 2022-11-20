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
    app.archive_map(:) = nan;
    app.map_stat(:) = 0;

    for i = 1 : size(app.results_enabled, 1) % user_id
        for j = 1 : size(app.results_enabled, 2) % env_id
            if app.results_enabled(i,j) == 1
                add_to_archive(app, app.results{i}.feature(j,:,:), app.results{i}.fitness(j,:), j);
            end
        end
    end

    surf_archive_map = zeros(size(app.archive_map));
    tmp_idx = ~isnan(app.archive_map);
    surf_archive_map(tmp_idx) = app.archive_map(tmp_idx);

    ref.map_surf.handle.ZData = surf_archive_map;
    ref.map_heat.ColorData = app.archive_map;

    % bar3(app.MapStatViewerAxes, app.map_stat, 1, 'b');
    ref.stat_bar.select();
    app.stacked_bar3(ref.stat_bar.axis, app.map_stat);
    title('Updates per Bin');
    xlabel(app.default_feature_description(2)); % x, y flipped in plot
    ylabel(app.default_feature_description(1));
    zlabel('Number of robots');

    heat_stat = nan(size(app.archive_map));
    map_stat_sum = sum(app.map_stat, 3);
    tmp_idx = (map_stat_sum > 0);
    heat_stat(tmp_idx) = map_stat_sum(tmp_idx);
    ref.stat_heat.ColorData = heat_stat;

    app.main_ref_plot = ref;
    update_plots_range(app, min(app.archive_map(:)), max(app.archive_map(:)));
end
