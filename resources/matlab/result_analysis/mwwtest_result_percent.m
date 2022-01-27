function report = mwwtest_result_percent(app, result1, result2, performance_percent)
% Assuming result1 and result2 are virtual results

    % check if result1 and result2 are virtual results
    if ~result1.isgroup || ~result2.isgroup
        report.valid = false;
        return
    end

    if performance_percent > 1 || performance_percent < 0
        disp(sprintf('Error: performance_percent %d', performance_percent));
    end

    samples = {};
    samples{1} = sample_result(app, result1, performance_percent);
    samples{2} = sample_result(app, result2, performance_percent);
    report.raw = samples;

    [report.P1, report.H1] = ranksum(samples{1}.fit_gen, samples{2}.fit_gen);
    [report.P2, report.H2] = ranksum(samples{1}.elite_fit_gen, samples{2}.elite_fit_gen);
end

function sample = sample_result(app, result, performance_percent)
    % first get the avg fits of the final gen
    sample.fit_gen = [];
    sample.elite_fit_gen = [];
    final_fits = [];
    final_elite_fits = [];
    for i = 1 : result.num_results
        child_result = load_target_result(app, false, result.ids(i));
        final_fits(i) = child_result.stat.archive_fits(end);
        final_elite_fits(i) = child_result.stat.elite_archive_fits(end);
    end
    sample.avg_final_fits = mean(final_fits);
    sample.avg_final_elite_fits = mean(final_elite_fits);

    fit_thresh = sample.avg_final_fits * performance_percent;
    elite_fit_thresh = sample.avg_final_elite_fits * performance_percent;

    for i = 1 : result.num_results
        child_result = load_target_result(app, false, result.ids(i));

        % omitting the first 24 generations (as there is an init fitness drop at the beginning)
        fit_gen = find(child_result.stat.archive_fits(26:end) > fit_thresh, 1);
        if isempty(fit_gen)
            fit_gen = length(child_result.stat.archive_fits) - 1;
        else
            fit_gen = fit_gen + 24;
        end
        elite_fit_gen = find(child_result.stat.elite_archive_fits(26:end) > elite_fit_thresh, 1);
        if isempty(elite_fit_gen)
            elite_fit_gen = length(child_result.stat.elite_archive_fits) - 1;
        else
            elite_fit_gen = elite_fit_gen + 24;
        end

        sample.fit_gen(i) = fit_gen;
        sample.elite_fit_gen(i) = elite_fit_gen;
    end
end
