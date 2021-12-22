function run_ttest(app)
    if length(app.targets_to_compare) < 2
        msgbox('Add at least 2 results to ttest');
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

    report = ttest_all_archived(app, result1, result2, 2000);

    mbox = msgbox(sprintf(['Fits are equal\n', ...
                           '    All fits: H %d, P %d\n', ...
                           '    Elite fits: H %d, P %d\n', ...
                           'First fits larger than the second\n', ...
                           '    All fits: H %d, P %d\n', ...
                           '    Elite fits: H %d, P %d\n', ...
                           'Second fits larger than the first\n', ...
                           '    All fits: H %d, P %d\n', ...
                           '    Elite fits: H %d, P %d'], ...
                  report.H1, report.P1, report.H2, report.P2, report.H3, report.P3, ...
                  report.H4, report.P4, report.H5, report.P5, report.H6, report.P6), ...
                  sprintf('T-Test %s - %s Result', result1.name, result2.name));

    mbox.Position(3) = 300;
    mbox.Position(4) = 220;
    txt = findall(mbox, 'Type', 'Text');
    txt.FontSize = 16;
end
