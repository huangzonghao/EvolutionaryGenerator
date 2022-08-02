function build_pack_export_all_results(app)
% go through all results and build stats for every unbuilt ones
    if length(app.results) == 0
        return
    end
    num_results = length(app.results);
    export_dir = fullfile(app.result_group_path, 'Processed');
    [~, ~, ~] = mkdir(export_dir);
    wb = waitbar(double(0), ['Processing 1 / ', num2str(num_results)], 'Name', 'Processing all results');
    for i = 1 : num_results
        result = app.results{i};
        % build
        if isfile(fullfile(result.path, 'stat.mat'));
            continue;
        end
        evo_params = load_evo_params(result.path);
        build_stat(result.path, evo_params, app.DumpRobotsCheckBox.Value, [], false, []);

        % export
        export_result(result, export_dir);
        cmd_str = "start tar -czf " + export_dir + "/" + result.basename + "_processed.tar.gz -C " + export_dir + " " + result.basename;
        system(cmd_str);

        % pack
        cmd_str = "start tar -czf " + result.path + ".tar.gz -C " + app.result_group_path + " " +  result.basename;
        system(cmd_str);

        waitbar(double(i + 1) / double(num_results), wb, sprintf("Processing %d / %d", i + 1, num_results));
    end
    close(wb);
    refresh_result_list(app);
end
