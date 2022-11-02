function clean_results(app)
% Remove the memory dumps recorded during training, keep only the last 3 and the first one
    num_results = length(app.ResultsListBox.Value);
    if num_results == 0
        msgbox('Select results to clean');
        return
    end

    wb = waitbar(double(0), ['Processing 1 / ', num2str(num_results)], 'Name', 'Cleaning selected results');
    for i = 1 : num_results
        waitbar(double(i) / double(num_results), wb, sprintf("Cleaning %d / %d", i + 1, num_results));
        app.clean_result(app.results{app.ResultsListBox.Value{i}});
    end
    close(wb);
end
