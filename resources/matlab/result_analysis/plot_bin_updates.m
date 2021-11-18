function plot_bin_updates(app)
    map_stat = app.stat.map_stat(:, :, end);
    h = figure('units','normalized','outerposition',[0.05 0 0.6 0.5]);
    p = panel(h);
    p.marginright = 20; % for the heatmap color bar
    p.pack('h', {1/2, 1/2});
    p(1).select();
    bar3(map_stat, 1, 'b');
    xlim([0.5, app.evo_params.griddim_1 + 0.5]);
    ylim([0.5, app.evo_params.griddim_0 + 0.5]);
    p(2).select();
    heatmap(map_stat);
end
