function pack_selected_results(app)
    num_results = length(app.ResultsListBox.Value);
    if num_results == 0
        msgbox('Select results to pack');
        return
    end
    wb = waitbar(double(0), ['Processing 1 / ', num2str(num_results)], 'Name', 'Processing Selected results');
    for i = 1 : num_results
        result = app.results{app.ResultsListBox.Value{i}};
        app.pack_result(result.path);
        waitbar(double(i + 1) / double(num_results), wb, sprintf("Processing %d / %d", i + 1, num_results));
    end
    close(wb);
end
