function open_plot(app)
    if ishandle(app.plot_fig)
        figure(app.plot_fig);
        return
    end
    app.plot_fig = figure('units','normalized','outerposition',[0 0 1 1]);
    app.panel = panel(app.plot_fig);
    app.panel.pack(1, 2);
    app.panel.de.margin = 20;
    psurf = app.panel(1, 1);
    pheat = app.panel(1, 2);
    psurf.pack(2,2);
    pheat.pack(2,2);
    pheat.de.margin = 30;

    app.map_surf = psurf(1, 1);
    app.stat_bar = psurf(1, 2);
    app.left_surf = psurf(2, 1);
    app.right_surf = psurf(2, 2);

    app.map_heat = pheat(1, 1);
    app.stat_heat = pheat(1, 2);
    app.left_heat = pheat(2, 1);
    app.right_heat = pheat(2, 2);

    app.panel.select('all');
end
