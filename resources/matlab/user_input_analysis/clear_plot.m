function clear_plot(app)
    app.archive_map(:) = 0;
    app.map_stat(:) = 0;
    surf(app.map_surf, app.archive_map);
    surf(app.left_surf, app.archive_map);
    surf(app.right_surf, app.archive_map);
    stacked_bar3(app.stat_bar, app.map_stat);
    heatmap(app.map_heat, app.archive_map);
    heatmap(app.left_heat, app.archive_map);
    heatmap(app.right_heat, app.archive_map);
    heatmap(app.stat_heat, app.map_stat);
end
