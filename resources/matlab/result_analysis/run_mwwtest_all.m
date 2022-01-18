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
mwwtest_name = strcat('gen_', num2str(mwwtest_gen));

timestamp = datestr(now,'yyyy-mm-dd_HHMMSS');
for i_group = 1 : size(test_plan, 1)
    fid = fopen(fullfile(app.result_group_path, 'tests', strcat('mwwtest_', mwwtest_name, '_g', num2str(i_group), '_', timestamp, '.txt')), 'wt');
    for i = 1 : size(test_plan, 2) - 1
        result_i = load_target_result(app, true, test_plan(i_group, i));
        for j = i + 1 : size(test_plan, 2)
            result_j = load_target_result(app, true, test_plan(i_group, j));
            report = mwwtest_kernel(app, result_i, result_j, mwwtest_gen);

            fprintf(fid, ['======================\n', ...
                          'Mann Whitney Test %s for %s - %s\n', ...
                          '----------------------\n', ...
                          'All fits: H %d, P %d\n', ...
                          'Elite fits: H %d, P %d\n', ...
                          '======================\n\n'], ...
                    mwwtest_name, result_i.name, result_j.name, ...
                    report.H1, report.P1, report.H2, report.P2);
        end
    end
    fclose(fid);
end
msgbox('Done', 'MWW-Test Manager');
end
