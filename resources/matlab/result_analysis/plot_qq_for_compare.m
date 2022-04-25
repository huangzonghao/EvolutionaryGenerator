function plot_qq_for_compare(app)
    if length(app.targets_to_compare) < 2
        msgbox('Add at least 2 results to ttest');
        return
    end
    % plot qq for the first two virtual results in the compare list
    if app.targets_to_compare{1}.isgroup
        result1 = app.virtual_results{app.targets_to_compare{1}.id};
    else
        result1 = app.results{app.targets_to_compare{1}.id};
    end
    if app.targets_to_compare{2}.isgroup
        result2 = app.virtual_results{app.targets_to_compare{2}.id};
    else
        result2 = app.results{app.targets_to_compare{2}.id};
    end

    % qq plot for each individual tests
    fitness1 = [];
    fitness2 = [];
    % gather all fitness and genearte the qq plot
    for i = 1 : result1.num_results
        child_result = load_target_result(app, false, result1.ids(i));
        gen_archive = child_result.archive{2000};
        final_fits = gen_archive(:, 5);
        fitness1 = [fitness1; final_fits];
    end
    for i = 1 : result2.num_results
        child_result = load_target_result(app, false, result2.ids(i));
        gen_archive = child_result.archive{2000};
        final_fits = gen_archive(:, 5);
        fitness2 = [fitness2; final_fits];
    end

    figure();
    qqplot(fitness1, fitness2);
    title(sprintf('QQ Plot %s - %s', result1.name, result2.name), 'Interpreter', 'none');
end
