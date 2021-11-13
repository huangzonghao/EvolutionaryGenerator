function plot_bin_updates(app)
    if app.stat_loaded
        map_stat = app.stat.map_stat;
    else
        map_stat = zeros(app.evo_params.griddim_0, app.evo_params.griddim_1);
        for i = 0 : app.current_gen
            map_stat = map_stat + readmatrix(fullfile(app.result_path, strcat('/gridstats/', num2str(i), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
        end
    end
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
