function run_mwwtest_percent_all(app)
% Run pair-wise mwwtest for all virtual results

% number is the internal id of virtual results
% each row is a test group
test_plan = [1, 2, 3, 4, 5;
             6, 7, 8, 9, 10;
             11, 12, 13, 14, 15];

test_root_dir = fullfile(app.result_group_path, 'tests');
if ~isfolder(test_root_dir)
    mkdir(test_root_dir);
end

coverage_percent = app.mwwPercentEditField.Value;

mwwtest_kernel = @mwwtest_result_coverage;
mwwtest_name = strcat('coverage_', num2str(coverage_percent * 100));

timestamp = datestr(now,'yyyy-mm-dd_HHMMSS');
for i_group = 1 : size(test_plan, 1)
    fid = fopen(fullfile(app.result_group_path, 'tests', strcat('mwwtest_on_coverage_', mwwtest_name, '_g', num2str(i_group), '_', timestamp, '.txt')), 'wt');
    for i = 1 : size(test_plan, 2) - 1
        result_i = load_target_result(app, true, test_plan(i_group, i));
        for j = i + 1 : size(test_plan, 2)
            result_j = load_target_result(app, true, test_plan(i_group, j));
            report = mwwtest_kernel(app, result_i, result_j, coverage_percent);
            raw = report.raw;
            fprintf(fid, ['=================================================\n', ...
                          'Mann Whitney Test %s for %s - %s\n', ...
                          '-------------------------------------------------\n', ...
                          '%d %% of final Coverage: H %d, P %d\n', ...
                          'result 1 avg cov gen: %.2f\n', ...
                          'result 1 all cov gen raw: %s\n', ...
                          'result 2 avg cov gen: %.2f\n', ...
                          'result 2 all cov gen raw: %s\n', ...
                          '=================================================\n\n'], ...
                    mwwtest_name, result_i.name, result_j.name, ...
                    coverage_percent * 100, report.H1, report.P1, ...
                    mean(raw{1}.cov_gen), format_array(raw{1}.cov_gen), ...
                    mean(raw{2}.cov_gen), format_array(raw{2}.cov_gen));
        end
    end
    fclose(fid);
end
msgbox('Done', 'MWW-Test Manager');
end

function str = format_array(array)
    str = sprintf('%d, ', array);
    str = str(1:end-2);
end
