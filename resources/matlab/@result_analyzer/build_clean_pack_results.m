function build_clean_pack_results(app)
% Go through the selected results or the results that haven't been built before
% Build, clean and than pack the results
% The purpose for this function is that you don't need to wait for the build
% to finish first and then click pack
% The ideal use case is to process and pack a newly finished training group

    if length(app.ResultsListBox.Value) > 0
        result_idxs = cell2mat(app.ResultsListBox.Value);
        num_results = length(app.ResultsListBox.Value);
        use_selected = true;
    elseif length(app.results) > 0
        num_results = length(app.results);
        result_idxs = 1 : num_results;
        use_selected = false;
    else
        return
    end

    % export_dir = fullfile(app.result_group_path, 'Processed');
    % if ~isfolder(export_dir)
        % mkdir(export_dir);
    % end

    wb = waitbar(double(0), ['Processing 1 / ', num2str(num_results)], 'Name', 'Processing all results');
    wb.Position(2) = wb.Position(2) - wb.Position(4);
    for i = 1 : num_results
        waitbar(double(i) / double(num_results), wb, sprintf("Processing %d / %d - building", i, num_results));

        result = app.results{result_idxs(i)};
        % build
        if ~isfile(fullfile(result.path, 'stat.mat'));
            app.build_stat(result, app.DumpRobotsCheckBox.Value, [], false);
        elseif ~use_selected
            continue
        end

        % clean
        wb.Children.Title.String = sprintf("Processing %d / %d - cleaning", i, num_results);
        app.clean_result(result);

        % export
        % wb.Children.Title.String = sprintf("Processing %d / %d - exporting", i, num_results);
        % app.export_result(result, export_dir);

        % pack
        % app.pack_result(fullfile(export_dir, result.basename));
        wb.Children.Title.String = sprintf("Processing %d / %d - packing", i, num_results);
        app.pack_result(result.path);
    end

    close(wb);
    refresh_result_list(app);
end
