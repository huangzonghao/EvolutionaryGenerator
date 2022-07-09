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

performance_percent = app.mwwPercentEditField.Value;
if performance_percent < 0
    msgbox('Error: percentage is negative');
    return
elseif performance_percent > 1
    if performance_percent <= 100
        performance_percent = performance_percent / 100;
    else
        msgbox('Error: percentage invalid');
        return
    end
end

mwwtest_kernel = @mwwtest_fitness_percentage;
mwwtest_name = strcat('percent_', num2str(performance_percent * 100));

timestamp = datestr(now,'yyyy-mm-dd_HHMMSS');
sumfile_id = fopen(fullfile(app.result_group_path, 'tests', strcat('mwwtest_on_', mwwtest_name, '_', timestamp, '_sum_report.txt')), 'wt');
best_sumfile_id = fopen(fullfile(app.result_group_path, 'tests', strcat('mwwtest_on_', mwwtest_name, '_', timestamp, '_best_sum_report.txt')), 'wt');
for i_group = 1 : size(test_plan, 1)
    fid = fopen(fullfile(app.result_group_path, 'tests', strcat('mwwtest_on_performance_', mwwtest_name, '_g', num2str(i_group), '_', timestamp, '.txt')), 'wt');
    for i = 1 : size(test_plan, 2) - 1
        result_i = load_target_result(app, true, test_plan(i_group, i));
        i_tab = i - 1;
        while i_tab > 0
            fprintf(sumfile_id, '\t');
            fprintf(best_sumfile_id, '\t');
            i_tab = i_tab - 1;
        end
        for j = i + 1 : size(test_plan, 2)
            result_j = load_target_result(app, true, test_plan(i_group, j));
            report = mwwtest_kernel(app, result_i, result_j, performance_percent);
            raw = report.raw;
            fprintf(fid, ['=================================================\n', ...
                          'Mann Whitney Test %s for %s - %s\n', ...
                          '-------------------------------------------------\n', ...
                          '%d %% of final All Fits: H %d, P %d\n', ...
                          '%d %% of final best fits: H %d, P %d\n', ...
                          '%s:\n', ...
                          '    avg final all fits: %.2f, avg final best fits: %.2f\n', ...
                          '    avg gen for all fits: %.2f, avg gen for best fits: %.2f\n', ...
                          '    all fits gen raw: %s\n', ...
                          '    best fits gen raw: %s\n', ...
                          '%s:\n', ...
                          '    avg final all fits: %.2f, avg final best fits: %.2f\n', ...
                          '    avg gen for all fits: %.2f, avg gen for best fits: %.2f\n', ...
                          '    all fits gen raw: %s\n', ...
                          '    best fits gen raw: %s\n', ...
                          '=================================================\n\n'], ...
                    mwwtest_name, result_i.name, result_j.name, ...
                    performance_percent * 100, report.H1, report.P1, ...
                    performance_percent * 100, report.H2, report.P2, ...
                    result_i.name, ...
                    raw{1}.avg_final_fits, raw{1}.avg_final_best_fits, mean(raw{1}.fit_gen), mean(raw{1}.best_fit_gen), format_array(raw{1}.fit_gen), format_array(raw{1}.best_fit_gen), ...
                    result_j.name, ...
                    raw{2}.avg_final_fits, raw{2}.avg_final_best_fits, mean(raw{2}.fit_gen), mean(raw{2}.best_fit_gen), format_array(raw{2}.fit_gen), format_array(raw{2}.best_fit_gen));

            fprintf(sumfile_id, 'H: %d, P: %d, L: %.2f, R: %.2f\t', report.H1, report.P1, mean(raw{1}.fit_gen), mean(raw{2}.fit_gen));
            fprintf(best_sumfile_id, 'H: %d, P: %d, L: %.2f, R: %.2f\t', report.H2, report.P2, mean(raw{1}.best_fit_gen), mean(raw{2}.best_fit_gen));
        end
        fprintf(sumfile_id, '\n');
        fprintf(best_sumfile_id, '\n');
    end
    fprintf(sumfile_id, '\n\n');
    fprintf(best_sumfile_id, '\n\n');
    fclose(fid);
end
fclose(sumfile_id);
fclose(best_sumfile_id);
msgbox('Done', 'MWW-Test Manager');
end

function str = format_array(array)
    str = sprintf('%d, ', array);
    str = str(1:end-2);
end
