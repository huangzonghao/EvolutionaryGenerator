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
    fig = figure('outerposition',[0, 40, 1920, 1000]);
    sgtitle(sprintf('QQ Plots for Individual Results of %s Against Normal Distribution', result.name), 'Interpreter', 'none');
    normal_qq_panel = panel(fig);
    normal_qq_panel.margintop = 20;
    normal_qq_panel.pack(2, 5);
    fig = figure('outerposition',[0, 40, 1920, 1000]);
    sgtitle(sprintf('QQ Plots for Individual Results of %s Against the First Result', result.name), 'Interpreter', 'none');
    first_qq_panel = panel(fig);
    first_qq_panel.margintop = 20;
    first_qq_panel.pack(2, 5);
    fitness = [];
    fit1 = [];
    % gather all fitness and genearte the qq plot
    for i = 1 : result.num_results
        child_result = app.results{result.ids(i)};
        if ~app.results{child_result.id}.loaded
            load_result(app, child_result.id);
            child_result = app.results{child_result.id};
        end
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

    figure();
    qqplot(fitness(:));
    title(sprintf('QQ Plot - %s', result.name), 'Interpreter', 'none');
end
