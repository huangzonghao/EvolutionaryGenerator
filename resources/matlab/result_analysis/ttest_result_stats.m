function report = ttest_result_stats(app, result1, result2, gen)
% Running ttest for the stats of all training sessions
% Assuming result1 and result2 are virtual results

    % check if result1 and result2 are virtual results
    if ~result1.isgroup || ~result2.isgroup
        report.valid = false;
        return
    end

    samples = {};
    samples{1} = sample_result(app, result1, gen);
    samples{2} = sample_result(app, result2, gen);

    [report.H1, report.P1] = ttest2(samples{1}.fits, samples{2}.fits);
    [report.H2, report.P2] = ttest2(samples{1}.elite_fits, samples{2}.elite_fits);
    [report.H3, report.P3] = ttest2(samples{1}.fits, samples{2}.fits, 'tail', 'left');
    [report.H4, report.P4] = ttest2(samples{1}.elite_fits, samples{2}.elite_fits, 'tail', 'left');
    [report.H5, report.P5] = ttest2(samples{1}.fits, samples{2}.fits, 'tail', 'right');
    [report.H6, report.P6] = ttest2(samples{1}.elite_fits, samples{2}.elite_fits, 'tail', 'right');
end

function sample = sample_result(app, result, gen)
    sample.fits = [];
    sample.elite_fits = [];
    for i = 1 : result.num_results
        child_result = load_target_result(app, false, result.ids(i));
        sample.fits(i) = child_result.stat.archive_fits(gen + 1);
        sample.elite_fits(i) = child_result.stat.elite_archive_fits(gen + 1);
    end
end
