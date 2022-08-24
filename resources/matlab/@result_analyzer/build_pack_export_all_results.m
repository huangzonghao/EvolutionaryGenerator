function build_pack_export_all_results(app)
% Go through all results and build stats for every unbuilt ones
% The purpose for this function is that you don't need to wait for the build
% to finish first and then click pack
% The ideal use case is to process and pack a newly finished training group
    num_results = length(app.results);
    if num_results == 0
        return
    end
    export_dir = fullfile(app.result_group_path, 'Processed');
    [~, ~, ~] = mkdir(export_dir);
    wb = waitbar(double(0), ['Processing 1 / ', num2str(num_results)], 'Name', 'Processing all results');
    for i = 1 : num_results
        result = app.results{i};
        % build
        if ~isfile(fullfile(result.path, 'stat.mat'));
            app.build_stat(result, app.DumpRobotsCheckBox.Value, [], false, []);
        end

        % export
        app.export_result(result, export_dir);

        % pack
        app.pack_result(fullfile(export_dir, result.basename));

        waitbar(double(i + 1) / double(num_results), wb, sprintf("Processing %d / %d", i + 1, num_results));
    end
    close(wb);
    refresh_result_list(app);
end
