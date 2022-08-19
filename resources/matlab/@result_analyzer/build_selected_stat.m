function build_selected_stat(app)
    num_results = length(app.ResultsListBox.Value);
    wb = waitbar(double(0), ['Processing 1 / ', num2str(num_results)], 'Name', 'Processing Selected results');
    for i = 1 : num_results
        result = app.results{app.ResultsListBox.Value{i}};
        app.build_stat(result, app.DumpRobotsCheckBox.Value, [], false);
        waitbar(double(i + 1) / double(num_results), wb, sprintf("Processing %d / %d", i + 1, num_results));
    end
    close(wb);
    refresh_result_list(app);
end
