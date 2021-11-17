function plot_gen_all(app)
% Plot all plots related to a specific generation
    if ~isfield(app.gen_plot, 'handle') || ~ishandle(app.gen_plot.handle)
        app.gen_plot.handle = figure();
        % app.gen_plot.handle = figure('units','normalized','outerposition',[0 0 0.8 0.8]);
        app.gen_plot.archive_surf_ax = newplot(app.gen_plot.handle);
    end
    plot_archive_map(app);
end
