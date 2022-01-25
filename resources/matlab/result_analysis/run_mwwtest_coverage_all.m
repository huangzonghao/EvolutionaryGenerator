function run_mwwtest_coverage_all(app)
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
if coverage_percent < 0
    msgbox('Error: percentage is negative');
    return
elseif coverage_percent > 1
    if coverage_percent <= 100
        coverage_percent = coverage_percent / 100;
    else
        msgbox('Error: percentage invalid');
        return
    end
end

mwwtest_kernel = @mwwtest_result_coverage;
mwwtest_name = strcat('coverage_', num2str(coverage_percent * 100));

timestamp = datestr(now,'yyyy-mm-dd_HHMMSS');
sumfile_id = fopen(fullfile(app.result_group_path, 'tests', strcat('mwwtest_on_', mwwtest_name, '_', timestamp, '_sum_report.txt')), 'wt');
for i_group = 1 : size(test_plan, 1)
    fid = fopen(fullfile(app.result_group_path, 'tests', strcat('mwwtest_on_', mwwtest_name, '_g', num2str(i_group), '_', timestamp, '.txt')), 'wt');
    for i = 1 : size(test_plan, 2) - 1
        result_i = load_target_result(app, true, test_plan(i_group, i));
        i_tab = i - 1;
        while i_tab > 0
            fprintf(sumfile_id, '\t');
            i_tab = i_tab - 1;
        end
        for j = i + 1 : size(test_plan, 2)
            result_j = load_target_result(app, true, test_plan(i_group, j));
            report = mwwtest_kernel(app, result_i, result_j, coverage_percent);
            raw = report.raw;
            result_i_mean = mean(raw{1}.cov_gen);
            result_j_mean = mean(raw{2}.cov_gen);
            fprintf(fid, ['=================================================\n', ...
                          'Mann Whitney Test %s for %s - %s\n', ...
                          '-------------------------------------------------\n', ...
                          '%d %% of final Coverage: H %d, P %d\n', ...
                          '%s\n', ...
                          '    avg gen to reach coverage: %.2f\n', ...
                          '    raw data: %s\n', ...
                          '%s\n', ...
                          '    avg gen to reach coverage: %.2f\n', ...
                          '    raw data: %s\n', ...
                          '=================================================\n\n'], ...
                    mwwtest_name, result_i.name, result_j.name, ...
                    coverage_percent * 100, report.H1, report.P1, ...
                    result_i.name, result_i_mean, format_array(raw{1}.cov_gen), ...
                    result_j.name, result_j_mean, format_array(raw{2}.cov_gen));

            fprintf(sumfile_id, 'H: %d, P: %d, L: %.2f, R: %.2f\t', report.H1, report.P1, result_i_mean, result_j_mean);
        end
        fprintf(sumfile_id, '\n');
    end
    fprintf(sumfile_id, '\n\n');
    fclose(fid);
end
fclose(sumfile_id);
msgbox('Done', 'MWW-Test Manager');
end

function str = format_array(array)
    str = sprintf('%d, ', array);
    str = str(1:end-2);
end
