function open_gen_all_plot(app)
    if isempty(app.current_result)
        return
    end
    result = app.current_result;

    app.plot_handles.gen_plot.handle = figure('outerposition',[180, 40, 1600, 1000]); % size for 1080p monitor
    if result.plot_to_file
        app.plot_handles.gen_plot.handle.Visible = 'off';
    end

    app.plot_handles.gen_plot.panel = panel(app.plot_handles.gen_plot.handle);
    app.plot_handles.gen_plot.panel.marginright = 20; % so that we have some space for the heatmap colorbar
    app.plot_handles.gen_plot.panel.pack('v', {1/100, 99/100});
    app.plot_handles.gen_plot.panel(1).select();
    axis off
    app.plot_handles.gen_plot.info_text = text(0, 0.8, "Gen Info");
    app.plot_handles.gen_plot.info_text.FontSize = 16;
    app.plot_handles.gen_plot.info_text.FontWeight = 'bold';
    app.plot_handles.gen_plot.info_text.Interpreter = 'none';

    plot_panel = app.plot_handles.gen_plot.panel(2);
    plot_panel.pack(2, 3);
    plot_panel.de.margintop = 20;
    plot_panel.de.marginbottom = 20;
    plot_panel.de.marginleft = 20;
    plot_panel.de.marginright = 30;

    % init all plots
    plot_panel(1,1).select();
    app.plot_handles.gen_plot.archive_surf = surf(zeros(result.evo_params.griddim_0, result.evo_params.griddim_1));
    xlabel(result.evo_params.feature_description2); % x, y flipped in plot
    ylabel(result.evo_params.feature_description1);
    % TODO: for some reason, setting the title font here doesn't work.
    app.plot_handles.gen_plot.archive_surf_title = title('Archive Map', 'FontWeight', 'bold', 'FontSize', 12);
    axis square;

    plot_panel(2,1).select();
    app.plot_handles.gen_plot.archive_hist = histogram(0);
    app.plot_handles.gen_plot.archive_hist_title = title('Fitness Histogram', 'FontWeight', 'bold', 'FontSize', 12);

    plot_panel(1,2).select();
    app.plot_handles.gen_plot.archive_heat = heatmap(zeros(result.evo_params.griddim_0, result.evo_params.griddim_1));
    app.plot_handles.gen_plot.archive_heat.NodeChildren(3).YDir='normal';
    app.plot_handles.gen_plot.archive_heat.XLabel = result.evo_params.feature_description2;
    app.plot_handles.gen_plot.archive_heat.YLabel = result.evo_params.feature_description1;
    app.plot_handles.gen_plot.archive_heat.Title = 'Archive Map';
    app.plot_handles.gen_plot.archive_heat.MissingDataLabel = 'Nan';
    app.plot_handles.gen_plot.archive_heat.MissingDataColor = [1, 1, 1];
    colormap(app.plot_handles.gen_plot.archive_heat, 'jet');

    plot_panel(1,3).select();
    app.plot_handles.gen_plot.parentage_heat = heatmap(double(-1) * ones(result.evo_params.griddim_0, result.evo_params.griddim_1));
    app.plot_handles.gen_plot.parentage_heat.ColorLimits = [0, 1];
    app.plot_handles.gen_plot.parentage_heat.NodeChildren(3).YDir='normal';
    app.plot_handles.gen_plot.parentage_heat.XLabel = result.evo_params.feature_description2;
    app.plot_handles.gen_plot.parentage_heat.YLabel = result.evo_params.feature_description1;
    app.plot_handles.gen_plot.parentage_heat.Title = 'Percentage of User Input Per Robot';
    app.plot_handles.gen_plot.parentage_heat.MissingDataLabel = 'Nan';
    app.plot_handles.gen_plot.parentage_heat.MissingDataColor = [1, 1, 1];
    colormap(app.plot_handles.gen_plot.parentage_heat, 'jet');

    plot_panel(2,2).select();
    app.plot_handles.gen_plot.updates_per_bin_heat = heatmap(double(-1) * ones(result.evo_params.griddim_0, result.evo_params.griddim_1));
    app.plot_handles.gen_plot.updates_per_bin_heat.NodeChildren(3).YDir='normal';
    app.plot_handles.gen_plot.updates_per_bin_heat.XLabel = result.evo_params.feature_description2;
    app.plot_handles.gen_plot.updates_per_bin_heat.YLabel = result.evo_params.feature_description1;
    app.plot_handles.gen_plot.updates_per_bin_heat.Title = 'Total Updates Per Bin';
    app.plot_handles.gen_plot.updates_per_bin_heat.MissingDataLabel = 'Nan';
    app.plot_handles.gen_plot.updates_per_bin_heat.MissingDataColor = [1, 1, 1];
    app.plot_handles.gen_plot.updates_per_bin_heat.CellLabelColor = 'none';
    colormap(app.plot_handles.gen_plot.updates_per_bin_heat, 'jet');

    plot_panel(2,3).select();
    app.plot_handles.gen_plot.bin_age_heat = heatmap(double(-1) * ones(result.evo_params.griddim_0, result.evo_params.griddim_1));
    app.plot_handles.gen_plot.bin_age_heat.NodeChildren(3).YDir='normal';
    app.plot_handles.gen_plot.bin_age_heat.XLabel = result.evo_params.feature_description2;
    app.plot_handles.gen_plot.bin_age_heat.YLabel = result.evo_params.feature_description1;
    app.plot_handles.gen_plot.bin_age_heat.Title = 'Age of Each Bin';
    app.plot_handles.gen_plot.bin_age_heat.MissingDataLabel = 'Nan';
    app.plot_handles.gen_plot.bin_age_heat.MissingDataColor = [1, 1, 1];
    colormap(app.plot_handles.gen_plot.bin_age_heat, 'jet');
end
