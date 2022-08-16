function report = mwwtest_result_fitness(app, v_result_1, v_result_2, gen)
% mwwtest on the mean archive fitness and best fitness of the given generation of
%     the given 2 virtual results
% v_result_1 and v_result_2 are virtual results

    % check if v_result_1 and v_result_2 are virtual results
    if ~v_result_1.isgroup || ~v_result_2.isgroup
        report.valid = false;
        return
    end

    samples = {};
    samples{1} = sample_result(app, v_result_1, gen);
    samples{2} = sample_result(app, v_result_2, gen);

    report.raw = samples;
    [report.P1, report.H1] = ranksum(samples{1}.fits, samples{2}.fits);
    [report.P2, report.H2] = ranksum(samples{1}.best_fits, samples{2}.best_fits);
end

function sample = sample_result(app, result, gen)
    sample.fits = [];
    sample.best_fits = [];
    for i = 1 : result.num_results
        child_result = load_target_result(app, false, result.ids(i));
        sample.fits(i) = child_result.stat.archive_fits(gen + 1); % stat.archive_fits are the mean fits of each generation
        sample.best_fits(i) = child_result.stat.best_fits(gen + 1);
        % sample.fits(i) = child_result.stat.clean_archive_fits(gen + 1);
        % sample.elite_fits(i) = child_result.stat.clean_elite_archive_fits(gen + 1);
    end
    sample.fits_mean = mean(sample.fits);
    sample.best_fits_mean = mean(sample.best_fits);
end
