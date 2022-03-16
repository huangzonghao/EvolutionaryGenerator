function build_all_stat(app)
% go through all results and build stats for every unbuilt ones
    if length(app.results) == 0
        return
    end
    num_results = length(app.results);
    wb = waitbar(double(0), ['Processing 1 / ', num2str(num_results)], 'Name', 'Processing all results');
    for i = 1 : num_results
        result_path = app.results{i}.path;
        if isfile(fullfile(result_path, 'stat.mat'));
            continue;
        end
        evo_params = load_evo_params(result_path);
        build_stat(result_path, evo_params, [], false, []);
        waitbar(double(i + 1) / double(num_results), wb, sprintf("Processing %d / %d", i + 1, num_results));
    end
    close(wb);
    refresh_result_list(app);
end
