function report = ttest_all_archived(app, result1, result2, gen)
% Running ttest for all robots of the archives of the same generation through all training sessions
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
    if result.isgroup % virtual result
        for i = 1 : result.num_results
            child_result = load_target_result(app, false, result.ids(i));
            gen_archive = child_result.archive{gen};
            final_fits = gen_archive(:, 5);
            elite_final_fits = maxk(final_fits, ceil(length(final_fits) * 0.1));
            sample.fits = [sample.fits; final_fits];
            sample.elite_fits = [sample.elite_fits; elite_final_fits];
        end
    else % single result
        result = load_target_result(app, false, result.id);
        gen_archive = result.archive{gen};
        final_fits = gen_archive(:, 5);
        elite_final_fits = maxk(final_fits, ceil(length(final_fits) * 0.1));
        sample.fits = [sample.fits; final_fits];
        sample.elite_fits = [sample.elite_fits; elite_final_fits];
    end
end
