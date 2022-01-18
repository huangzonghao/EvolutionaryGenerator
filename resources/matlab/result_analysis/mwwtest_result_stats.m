function report = mwwtest_result_stats(app, result1, result2, gen)
% Running mwwtest for the stats of all training sessions
% Assuming result1 and result2 are virtual results

    % check if result1 and result2 are virtual results
    if ~result1.isgroup || ~result2.isgroup
        report.valid = false;
        return
    end

    samples = {};
    samples{1} = sample_result(app, result1, gen);
    samples{2} = sample_result(app, result2, gen);

    [report.P1, report.H1] = ranksum(samples{1}.fits, samples{2}.fits);
    [report.P2, report.H2] = ranksum(samples{1}.elite_fits, samples{2}.elite_fits);
end

function sample = sample_result(app, result, gen)
    sample.fits = [];
    sample.elite_fits = [];
    for i = 1 : result.num_results
        child_result = load_target_result(app, false, result.ids(i));
        % sample.fits(i) = child_result.stat.archive_fits(gen + 1);
        % sample.elite_fits(i) = child_result.stat.elite_archive_fits(gen + 1);
        sample.fits(i) = child_result.stat.clean_archive_fits(gen + 1);
        sample.elite_fits(i) = child_result.stat.clean_elite_archive_fits(gen + 1);
    end
end
