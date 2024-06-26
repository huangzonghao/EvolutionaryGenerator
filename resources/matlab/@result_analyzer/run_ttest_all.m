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

ttest_gen = 2000;

if app.TTestOptionDropDown.Value == 1
    ttest_kernel = @ttest_all_archived;
    ttest_name = 'AllRobots';
elseif app.TTestOptionDropDown.Value == 2
    ttest_kernel = @ttest_result_stats;
    ttest_name = 'TrainingStats';
end
ttest_name = strcat(ttest_name, '_gen_', num2str(ttest_gen));

timestamp = datestr(now,'yyyy-mm-dd_HHMMSS');
for i_group = 1 : size(test_plan, 1)
    fid = fopen(fullfile(app.result_group_path, 'tests', strcat('ttest_', ttest_name, '_g', num2str(i_group), '_', timestamp, '.txt')), 'wt');
    for i = 1 : size(test_plan, 2) - 1
        result_i = load_target_result(app, true, test_plan(i_group, i));
        for j = i + 1 : size(test_plan, 2)
            result_j = load_target_result(app, true, test_plan(i_group, j));
            report = ttest_kernel(app, result_i, result_j, ttest_gen);

            fprintf(fid, ['======================\n', ...
                          't-test %s for %s - %s\n', ...
                          '----------------------\n', ...
                          'Fits are equal\n', ...
                          '    All fits: H %d, P %d\n', ...
                          '    Elite fits: H %d, P %d\n', ...
                          'First fits larger than the second\n', ...
                          '    All fits: H %d, P %d\n', ...
                          '    Elite fits: H %d, P %d\n', ...
                          'Second fits larger than the first\n', ...
                          '    All fits: H %d, P %d\n', ...
                          '    Elite fits: H %d, P %d\n', ...
                          '======================\n\n'], ...
                    ttest_name, result_i.name, result_j.name, ...
                    report.H1, report.P1, report.H2, report.P2, ...
                    report.H3, report.P3, report.H4, report.P4, ...
                    report.H5, report.P5, report.H6, report.P6);
        end
    end
    fclose(fid);
end
msgbox('Done', 'T-Test Manager');
end
