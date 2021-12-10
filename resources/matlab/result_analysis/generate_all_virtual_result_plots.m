function generate_all_virtual_result_plots(app)
    wb = waitbar(0, 'Start Generating Plots', 'Name', 'Generating Single Reseult Plots');
    wb.Children.Title.Interpreter = 'none';
    num_results = length(app.VirtualResultsListBox.Value);
    if num_results == 0
        msgbox('Select results to generate plots');
    end
    root_dir = fullfile(app.result_group_path, 'plots', 'virtual_results');
    if ~isfolder(root_dir)
        mkdir(root_dir);
    end
    for i = 1 : num_results
        result = app.results{app.VirtualResultsListBox.Value(i)};
        waitbar((double(i) - 0.5) / double(num_results), wb, sprintf("Generating plots for %s (%d / %d)", result.name, i, num_results));
        generate_all_plots_for_this_virtual_result(app, i, root_dir);
    end
    close(wb);
end

function generate_all_plots_for_this_virtual_result(app, result_idx, root_dir)
    result_plot_dir = root_dir;
    % result_plot_dir = fullfile(root_dir, result.name);
    % if ~isfolder(result_plot_dir)
        % mkdir(result_plot_dir);
    % end

    app.current_virtual_result = app.virtual_results{result_idx};
    app.current_virtual_result.plot_to_file = true;
    app.current_virtual_result.plot_dir = result_plot_dir;
    app.current_virtual_result.plot_format = {'png', 'eps'};

    % Generating the plots
    plot_group_stat(app);

    app.current_virtual_result = {};
end
