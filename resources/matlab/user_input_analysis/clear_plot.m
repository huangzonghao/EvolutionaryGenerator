function clear_plot(app)
    app.archive_map(:) = 0;
    app.map_stat(:) = 0;
    surf(app.MapViewerAxes, app.archive_map);
    stacked_bar3(app.MapStatViewerAxes, app.map_stat);
end
