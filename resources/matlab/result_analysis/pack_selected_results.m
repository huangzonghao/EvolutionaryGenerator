function pack_selected_results(app)
    num_results = length(app.ResultsListBox.Value);
    wb = waitbar(double(0), ['Processing 1 / ', num2str(num_results)], 'Name', 'Processing Selected results');
    for i = 1 : num_results
        cmd_str = 'tar -czf ' + result_path + '.tar.gz ' + result_path;
        system(cmd_str);
        waitbar(double(i + 1) / double(num_results), wb, sprintf("Processing %d / %d", i + 1, num_results));
    end
    close(wb);
end
