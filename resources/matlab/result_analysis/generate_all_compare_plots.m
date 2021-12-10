function generate_all_compare_plots(app)
    if isempty(app.CompPlotNameField.Value)
        msgbox('Enter a name for the compare plot to continue');
        return
    end
    if length(app.results_to_compare) == 0
        msgbox('Add results to compare');
        return
    end

    app.compare_plot_config.plot_to_file = true;
    app.compare_plot_config.plot_format = {'png', 'eps'};
    root_dir = fullfile(app.result_group_path, 'plots', 'compare_plots');
    app.compare_plot_config.plot_dir = root_dir;
    if ~isfolder(root_dir)
        mkdir(root_dir);
    end

    plot_result_compares(app, true); % raw plot
    plot_result_compares(app, false); % clean plot

    app.compare_plot_config.plot_to_file = false;
    msgbox(sprintf("Compare plot saved to %s", root_dir));
end
