function plot_qq_for_virtual_result(app)
    if isempty(app.current_virtual_result)
        if isempty(app.VirtualResultsListBox.Value)
            msgbox('Select a virtual result');
            return
        end
        result = app.virtual_results{app.VirtualResultsListBox.Value(1)};
        result.plot_to_file = false;
    else
        result = app.current_virtual_result;
    end

    % qq plot for each individual tests
    normal_qq_fig = figure('outerposition',[0, 40, 1920, 1000]);
    if result.plot_to_file
        normal_qq_fig.Visible = 'off';
    end
    sgtitle(normal_qq_fig, sprintf('QQ Plots for Individual Results of %s Against Normal Distribution', result.name), 'Interpreter', 'none');
    normal_qq_panel = panel(normal_qq_fig);
    normal_qq_panel.margintop = 20;
    normal_qq_panel.pack(2, 5);
    first_qq_fig = figure('outerposition',[0, 40, 1920, 1000]);
    if result.plot_to_file
        first_qq_fig.Visible = 'off';
    end
    sgtitle(first_qq_fig, sprintf('QQ Plots for Individual Results of %s Against the First Result', result.name), 'Interpreter', 'none');
    first_qq_panel = panel(first_qq_fig);
    first_qq_panel.margintop = 20;
    first_qq_panel.pack(2, 5);
    fitness = [];
    fit1 = [];
    % gather all fitness and genearte the qq plot
    for i = 1 : result.num_results
        child_result = load_target_result(app, false, result.ids(i));
        gen_archive = child_result.archive{2000};
        result_fits = gen_archive(:, 5);
        if i == 1
            fit1 = result_fits;
        end
        fitness = [fitness; result_fits];
        normal_qq_panel(floor((i-1)/5) + 1, mod((i-1), 5) + 1).select();
        qqplot(result_fits);
        title(child_result.name, 'Interpreter', 'none');
        first_qq_panel(floor((i-1)/5) + 1, mod((i-1), 5) + 1).select();
        qqplot(result_fits, fit1);
        title(child_result.name, 'Interpreter', 'none');
    end

    group_qq_fig = figure();
    if result.plot_to_file
        group_qq_fig.Visible = 'off';
    end
    qqplot(fitness(:));
    title(sprintf('QQ Plot - %s', result.name), 'Interpreter', 'none');

    if result.plot_to_file
        for i_format = 1 : length(result.plot_format)
            saveas(normal_qq_fig, fullfile(result.plot_dir, ['qq_against_normal_', result.name, '.', result.plot_format{i_format}]));
            saveas(first_qq_fig, fullfile(result.plot_dir, ['qq_against_first_result_', result.name, '.', result.plot_format{i_format}]));
            saveas(group_qq_fig, fullfile(result.plot_dir, ['group_qq_', result.name, '.', result.plot_format{i_format}]));
        end

        close(normal_qq_fig);
        close(first_qq_fig);
        close(group_qq_fig);
    end
end
