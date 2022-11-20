function open_plot(app)
% main_ref_plot:
% fig panel
% map_surf map_heat
% stat_bar stat_heat
% left_surf left_heat
% right_surf right_heat

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

    ref.stat_bar = psurf(1, 2);

    map_size = size(app.archive_map);

    %% Surf plots
    psurf(1, 1).select();
    ref.map_surf.handle = surf(zeros(map_size));
    ref.map_surf.ax = gca;
    title(ref.map_surf.ax , 'Archive Map');
    xlabel(ref.map_surf.ax, app.default_feature_description(2));
    ylabel(ref.map_surf.ax, app.default_feature_description(1));
    zlabel(ref.map_surf.ax, 'Fitness');

    psurf(2, 1).select();
    ref.left_surf.handle = surf(zeros(map_size));
    ref.left_surf.ax = gca;

    psurf(2, 2).select();
    ref.right_surf.handle = surf(zeros(map_size));
    ref.right_surf.ax = gca;

    %% Heatmaps
    pheat(1, 1).select();
    ref.map_heat = heatmap(nan(map_size));
    ref.map_heat.NodeChildren(3).YDir='normal';
    ref.map_heat.Title = 'Archive Map';
    ref.map_heat.MissingDataLabel = 'Nan';
    ref.map_heat.MissingDataColor = [1, 1, 1];
    ref.map_heat.XLabel = app.default_feature_description(2); % x, y flipped in plot
    ref.map_heat.YLabel = app.default_feature_description(1);
    colormap(ref.map_heat, 'jet');

    pheat(1, 2).select();
    ref.stat_heat = heatmap(nan(map_size));
    ref.stat_heat.NodeChildren(3).YDir='normal';
    ref.stat_heat.Title = 'Updates Per Bin';
    ref.stat_heat.MissingDataLabel = 'Nan';
    ref.stat_heat.MissingDataColor = [1, 1, 1];
    ref.stat_heat.XLabel = app.default_feature_description(2); % x, y flipped in plot
    ref.stat_heat.YLabel = app.default_feature_description(1);
    colormap(ref.stat_heat, 'jet');

    pheat(2, 1).select();
    ref.left_heat = heatmap(nan(map_size));
    ref.left_heat.NodeChildren(3).YDir='normal';
    ref.left_heat.MissingDataLabel = 'Nan';
    ref.left_heat.MissingDataColor = [1, 1, 1];
    colormap(ref.left_heat, 'jet');

    pheat(2, 2).select();
    ref.right_heat = heatmap(nan(map_size));
    ref.right_heat.NodeChildren(3).YDir='normal';
    ref.right_heat.MissingDataLabel = 'Nan';
    ref.right_heat.MissingDataColor = [1, 1, 1];
    colormap(ref.right_heat, 'jet');

    ref.panel.select('all');
    app.main_ref_plot = ref;
end
