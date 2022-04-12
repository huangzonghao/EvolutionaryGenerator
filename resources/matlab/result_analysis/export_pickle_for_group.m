function export_pickle_for_group(app)
    % Export selected results to seperate pickle files
    num_results = length(app.ResultsListBox.Value);
    if num_results == 0
        msgbox('Select results to export pickle');
    end

    dest_path = uigetdir(app.evogen_results_path, 'Export Path');
    if dest_path == 0
        return
    end

    wb = waitbar(double(0), ['Exporting pickle files'], 'Name', 'Exporting result group');
    wb.Children.Title.Interpreter = 'none';

    for i = 1 : num_results
        result = app.results{app.ResultsListBox.Value{i}};

        waitbar(double(i) / double(num_results), wb, sprintf("Exporting pickle for %s (%d / %d)", result.name, i, num_results));
        cmd_str = "python " + ...
            app.evogen_python_path + "/data_converter/mat_to_pickle.py " + ...
            result.path + "  " + dest_path;
        system(cmd_str);
    end
    close(wb);
    figure(app.MainFigure);
end
