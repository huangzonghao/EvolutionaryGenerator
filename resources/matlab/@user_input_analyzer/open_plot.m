function open_plot(app)
    % fig
    % heat_axes
    % panel
    % map_surf
    % map_heat
    % stat_bar
    % stat_heat
    % left_surf
    % left_heat
    % right_surf
    % right_heat
    ref = app.main_ref_plot;
    if isfield(ref, 'fig') && ishandle(ref.fig)
        figure(ref.fig);
        return
    end
    app.fitness_range = [Inf, -Inf];
    ref.fig = figure('units','normalized','outerposition',[0 0 1 1]);
    ref.panel = panel(ref.fig);
    ref.panel.pack(1, 2);
    ref.panel.marginright = 20; % so that we have some space for the heatmap colorbar
    ref.panel.de.margin = 20;
    psurf = ref.panel(1, 1);
    pheat = ref.panel(1, 2);
    psurf.pack(2,2);
    pheat.pack(2,2);
    pheat.de.margin = 30;

    ref.map_surf = psurf(1, 1);
    ref.stat_bar = psurf(1, 2);
    ref.left_surf = psurf(2, 1);
    ref.right_surf = psurf(2, 2);

    ref.map_heat = pheat(1, 1);
    ref.stat_heat = pheat(1, 2);
    ref.left_heat = pheat(2, 1);
    ref.right_heat = pheat(2, 2);

    ref.panel.select('all');

    ref.heat_axes.map_heat = pheat(1, 1).axis;
    ref.heat_axes.stat_heat = pheat(1, 2).axis;
    ref.heat_axes.left_heat = pheat(2, 1).axis;
    ref.heat_axes.right_heat = pheat(2, 2).axis;

    app.main_ref_plot = ref;
end
