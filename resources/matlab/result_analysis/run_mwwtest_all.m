function run_mwwtest_all(app)
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

mwwtest_gen = app.mwwGenEditField.Value;

mwwtest_kernel = @mwwtest_result_stats;
mwwtest_name = strcat('fitness_of_gen_', num2str(mwwtest_gen));

timestamp = datestr(now,'yyyy-mm-dd_HHMMSS');
sumfile_id = fopen(fullfile(app.result_group_path, 'tests', strcat('mwwtest_on_', mwwtest_name, '_', timestamp, '_sum_report.txt')), 'wt');
elite_sumfile_id = fopen(fullfile(app.result_group_path, 'tests', strcat('mwwtest_on_', mwwtest_name, '_', timestamp, '_elite_sum_report.txt')), 'wt');
for i_group = 1 : size(test_plan, 1)
    fid = fopen(fullfile(app.result_group_path, 'tests', strcat('mwwtest_', mwwtest_name, '_g', num2str(i_group), '_', timestamp, '.txt')), 'wt');
    for i = 1 : size(test_plan, 2) - 1
        result_i = load_target_result(app, true, test_plan(i_group, i));
        i_tab = i - 1;
        while i_tab > 0
            fprintf(sumfile_id, '\t');
            fprintf(elite_sumfile_id, '\t');
            i_tab = i_tab - 1;
        end
        for j = i + 1 : size(test_plan, 2)
            result_j = load_target_result(app, true, test_plan(i_group, j));
            report = mwwtest_kernel(app, result_i, result_j, mwwtest_gen);
            raw = report.raw;
            fprintf(fid, ['===============================================================\n', ...
                          'Mann Whitney Test %s for %s - %s\n', ...
                          '---------------------------------------------------------------\n', ...
                          'Avg Fits of Map: H %d, P %d\n', ...
                          'Avg Elite Fits of Map: H %d, P %d\n', ...
                          '%s:\n', ...
                          '    Avg of Avg Fits of Map: %.4f, Avg of Avg Elite Fits of Map: %.4f\n', ...
                          '    Avg Fits Raw: %s\n', ...
                          '    Avg Elite Fits Raw: %s\n', ...
                          '%s:\n', ...
                          '    Avg of Avg Fits of Map: %.4f, Avg of Avg Elite Fits of Map: %.4f\n', ...
                          '    Avg Fits Raw: %s\n', ...
                          '    Avg Elite Fits Raw: %s\n', ...
                          '===============================================================\n\n'], ...
                    mwwtest_name, result_i.name, result_j.name, ...
                    report.H1, report.P1, report.H2, report.P2, ...
                    result_i.name, ...
                    raw{1}.fits_mean, raw{1}.elite_fits_mean, ...
                    format_array(raw{1}.fits), format_array(raw{1}.elite_fits), ...
                    result_j.name, ...
                    raw{2}.fits_mean, raw{2}.elite_fits_mean, ...
                    format_array(raw{2}.fits), format_array(raw{2}.elite_fits));

            fprintf(sumfile_id, 'H: %d, P: %d, L: %.2f, R: %.2f\t', report.H1, report.P1, raw{1}.fits_mean, raw{2}.fits_mean);
            fprintf(elite_sumfile_id, 'H: %d, P: %d, L: %.2f, R: %.2f\t', report.H2, report.P2, raw{1}.elite_fits_mean, raw{2}.elite_fits_mean);
        end
        fprintf(sumfile_id, '\n');
        fprintf(elite_sumfile_id, '\n');
    end
    fprintf(sumfile_id, '\n\n');
    fprintf(elite_sumfile_id, '\n\n');
    fclose(fid);
end
fclose(sumfile_id);
fclose(elite_sumfile_id);
msgbox('Done', 'MWW-Test Manager');
end

function str = format_array(array)
    str = sprintf('%.4f, ', array);
    str = str(1:end-2);
end
