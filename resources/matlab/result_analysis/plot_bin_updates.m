function plot_bin_updates(app)
    if isempty(app.current_result) || isempty(app.current_result.stat)
        return
    end
    result = app.current_result;
    map_stat = result.stat.map_stat(:, :, end);
    h = figure('units','normalized','outerposition',[0.2 0.2 0.6 0.6]);
    sgtitle(sprintf("%s - Number of Updates per Bin", result.name), 'Interpreter', 'none');
    p = panel(h);
    p.margintop = 20;
    p.marginright = 20; % for the heatmap color bar
    p.pack('h', {1/2, 1/2});
    p(1).select();
    bar3(map_stat, 1, 'b');
    xlim([0.5, result.evo_params.griddim_1 + 0.5]);
    ylim([0.5, result.evo_params.griddim_0 + 0.5]);
    p(2).select();
    heatmap(map_stat);
end
