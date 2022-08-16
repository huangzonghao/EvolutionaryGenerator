function report = mwwtest_fitness_percentage(app, v_result_1, v_result_2, avg_fitness_percentage)
% mwwtest on the number of generations that the average archive fitness reaches certain
%     percentage of the average of verage fitness of the final generation of all repeated test.
% v_result_1 and v_result_2 are virtual results

    % check if v_result_1 and v_result_2 are virtual results
    if ~v_result_1.isgroup || ~v_result_2.isgroup
        report.valid = false;
        return
    end

    if avg_fitness_percentage > 1 || avg_fitness_percentage < 0
        disp(sprintf('Error: avg_fitness_percentage %d', avg_fitness_percentage));
    end

    samples = {};
    samples{1} = sample_result(app, v_result_1, avg_fitness_percentage);
    samples{2} = sample_result(app, v_result_2, avg_fitness_percentage);
    report.raw = samples;

    [report.P1, report.H1] = ranksum(samples{1}.fit_gen, samples{2}.fit_gen);
    [report.P2, report.H2] = ranksum(samples{1}.best_fit_gen, samples{2}.best_fit_gen);
end

function sample = sample_result(app, result, avg_fitness_percentage)
    % first get the avg fits of the final gen
    sample.fit_gen = [];
    sample.best_fit_gen = [];
    final_fits = [];
    final_best_fits = [];
    for i = 1 : result.num_results
        child_result = load_target_result(app, false, result.ids(i));
        final_fits(i) = child_result.stat.archive_fits(end);
        final_best_fits(i) = child_result.stat.best_fits(end);
    end
    sample.avg_final_fits = mean(final_fits);
    sample.avg_final_best_fits = mean(final_best_fits);

    fit_thresh = sample.avg_final_fits * avg_fitness_percentage;
    best_fit_thresh = sample.avg_final_best_fits * avg_fitness_percentage;

    for i = 1 : result.num_results
        child_result = load_target_result(app, false, result.ids(i));

        % omitting the first 24 generations (as there is an init fitness drop at the beginning)
        fit_gen = find(child_result.stat.archive_fits(26:end) > fit_thresh, 1);
        if isempty(fit_gen)
            fit_gen = length(child_result.stat.archive_fits) - 1;
        else
            fit_gen = fit_gen + 24;
        end
        best_fit_gen = find(child_result.stat.best_fits(26:end) > best_fit_thresh, 1);
        if isempty(best_fit_gen)
            best_fit_gen = length(child_result.stat.best_fits) - 1;
        else
            best_fit_gen = best_fit_gen + 24;
        end

        sample.fit_gen(i) = fit_gen;
        sample.best_fit_gen(i) = best_fit_gen;
    end
end
