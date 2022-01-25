function report = mwwtest_result_coverage(app, result1, result2, coverage_percent)
% Assuming result1 and result2 are virtual results

    % check if result1 and result2 are virtual results
    if ~result1.isgroup || ~result2.isgroup
        report.valid = false;
        return
    end

    if coverage_percent > 1 || coverage_percent < 0
        disp(sprintf('Error: coverage_percent %d', coverage_percent));
    end

    samples = {};
    samples{1} = sample_result(app, result1, coverage_percent);
    samples{2} = sample_result(app, result2, coverage_percent);
    report.raw = samples;
    [report.P1, report.H1] = ranksum(samples{1}.cov_gen, samples{2}.cov_gen);
end

function sample = sample_result(app, result, coverage_percent)
    % first get the avg fits of the final gen
    sample.cov_gen = [];

    for i = 1 : result.num_results
        child_result = load_target_result(app, false, result.ids(i));

        cov_gen = find(child_result.stat.coverage > coverage_percent, 1);
        if isempty(cov_gen)
            cov_gen = child_result.evo_params.nb_gen;
        end
        cov_gen = cov_gen - 1;

        sample.cov_gen(i) = cov_gen;
    end
end
