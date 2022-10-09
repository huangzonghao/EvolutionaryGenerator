function generate_all_single_result_plots(app)
    wb = waitbar(0, 'Start Generating Plots', 'Name', 'Generating Single Reseult Plots');
    wb.Children.Title.Interpreter = 'none';
    num_results = length(app.ResultsListBox.Value);
    if num_results == 0
        msgbox('Select results to generate plots');
    end
    root_dir = fullfile(app.result_group_path, 'plots');
    if ~isfolder(root_dir)
        mkdir(root_dir);
    end
    for i = 1 : num_results
        result = load_target_result(app, false, app.ResultsListBox.Value{i});
        waitbar((double(i) - 0.5) / double(num_results), wb, sprintf("Generating plots for %s (%d / %d)", result.name, i, num_results));
        generate_all_plots_for_this_result(app, result, root_dir);
    end
    close(wb);
end

function generate_all_plots_for_this_result(app, result, root_dir)
    result_plot_dir = fullfile(root_dir, result.name);
    if ~isfolder(result_plot_dir)
        mkdir(result_plot_dir);
    end

    app.current_result = result;
    app.current_result.plot_to_file = true;
    app.current_result.plot_dir = result_plot_dir;
    app.current_result.plot_format = {'png', 'eps'};

    % Generating the plots
    plot_avg_age_of_map(app);
    plot_avg_longevity_of_gen(app);
    plot_bin_updates(app);
    plot_parentage_related(app);
    plot_parentage_stat(app);
    plot_result_stat(app);

    if isfield(app.plot_handles.gen_plot, 'handle') && ishandle(app.plot_handles.gen_plot.handle)
        close(app.plot_handles.gen_plot.handle);
    end

    % gen 0
    app.current_gen = 0;
    plot_gen_all(app);
    % mid gen
    app.current_gen = ceil(result.evo_params.nb_gen / 2);
    plot_gen_all(app);
    % final gen
    app.current_gen = result.evo_params.nb_gen;
    plot_gen_all(app);
    close(app.plot_handles.gen_plot.handle);

    app.current_result.plot_to_file = false;
end
