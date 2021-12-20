function run_ttest_all(app)
% Run pair-wise ttest for all virtual results

% number is the internal id of virtual results
% each row is a test group
test_plan = [1, 2, 3, 4, 5;
             6, 7, 8, 9, 10;
             11, 12, 13, 14, 15];

test_root_dir = fullfile(app.result_group_path, 'tests');
if ~isfolder(test_root_dir)
    mkdir(test_root_dir);
end
timestamp = datestr(now,'yyyy-mm-dd_HHMMSS');
for i_group = 1 : size(test_plan, 1)
    fid = fopen(fullfile(app.result_group_path, 'tests', strcat('ttest_g', num2str(i_group), '_', timestamp, '.txt')), 'wt');
    for i = 1 : size(test_plan, 2) - 1
        sample.fits = [];
        sample.elite_fits = [];
        result_i = load_target_result(app, true, test_plan(i_group, i));
        for i_child = 1 : result_i.num_results
            child_result = load_target_result(app, false, result_i.ids(i_child));
            final_gen_archive = child_result.archive{child_result.evo_params.nb_gen};
            final_fits = final_gen_archive(:, 5);
            elite_final_fits = maxk(final_fits, ceil(length(final_fits) * 0.1));
            sample.fits = [sample.fits; final_fits];
            sample.elite_fits = [sample.elite_fits; elite_final_fits];
        end
        samples{1} = sample;
        for j = i + 1 : size(test_plan, 2)
            sample.fits = [];
            sample.elite_fits = [];
            result_j = load_target_result(app, true, test_plan(i_group, j));

            for i_child = 1 : result_j.num_results
                child_result = load_target_result(app, false, result_j.ids(i_child));
                final_gen_archive = child_result.archive{child_result.evo_params.nb_gen};
                final_fits = final_gen_archive(:, 5);
                elite_final_fits = maxk(final_fits, ceil(length(final_fits) * 0.1));
                sample.fits = [sample.fits; final_fits];
                sample.elite_fits = [sample.elite_fits; elite_final_fits];
            end
            samples{2} = sample;

            % t_test for this pair
            [H1, P1] = ttest2(samples{1}.fits, samples{2}.fits);
            [H2, P2] = ttest2(samples{1}.elite_fits, samples{2}.elite_fits);
            [H3, P3] = ttest2(samples{1}.fits, samples{2}.fits, 'tail', 'left');
            [H4, P4] = ttest2(samples{1}.elite_fits, samples{2}.elite_fits, 'tail', 'left');
            [H5, P5] = ttest2(samples{1}.fits, samples{2}.fits, 'tail', 'right');
            [H6, P6] = ttest2(samples{1}.elite_fits, samples{2}.elite_fits, 'tail', 'right');
            fprintf(fid, "\n======================\nt-test for %s - %s\n---------------------\nFits are equal\n    All fits: H %d, P %d\n    Elite fits: H %d, P %d\nFirst fits larger than the second\n    All fits: H %d, P %d\n    Elite fits: H %d, P %d\nSecond fits larger than the first\n    All fits: H %d, P %d\n    Elite fits: H %d, P %d\n======================\n\n", result_i.name, result_j.name, H1, P1, H2, P2, H3, P3, H4, P4, H5, P5, H6, P6);
        end
    end
    fclose(fid);
end

end
