function run_mwwtest(app)
    if length(app.targets_to_compare) < 2
        msgbox('Add at least 2 results to mwwtest');
        return
    end

    if app.targets_to_compare{1}.isgroup
        result1 = app.virtual_results{app.targets_to_compare{1}.id};
    else
        result1 = app.results{app.targets_to_compare{1}.id};
    end
    if app.targets_to_compare{2}.isgroup
        result2 = app.virtual_results{app.targets_to_compare{2}.id};
    else
        result2 = app.results{app.targets_to_compare{2}.id};
    end

    mwwtest_gen = app.mwwGenEditField.Value;
    report = mwwtest_result_stats(app, result1, result2, mwwtest_gen);

    mbox = msgbox(sprintf(['All fits: H %d, P %d\n', ...
                           'Elite fits: H %d, P %d\n', ...
                          ], ...
                  report.H1, report.P1, report.H2, report.P2), ...
                  sprintf('Mann-Whitney U-Test %s - %s Result', result1.name, result2.name));

    mbox.Position(3) = 300;
    mbox.Position(4) = 220;
    txt = findall(mbox, 'Type', 'Text');
    txt.FontSize = 16;
end
