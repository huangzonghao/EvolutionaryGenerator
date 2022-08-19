function export_group(app)
    % Export the currently loaded result group to a new location
    % Only the built stat files would be exported, which are enough to generate
    % plots

    if isempty(app.results)
        msgbox("Error: No result loaded. Load a result group first");
        return
    end

    dest_path = uigetdir(app.evogen_results_path, 'Export Path');
    if dest_path == 0
        return
    end

    wb = waitbar(double(0), ['Processing group files'], 'Name', 'Exporting result group');

    source_group_dir = app.result_group_path;
    % TODO: somehow the following comparison won't work
    % if source_group_dir == app.evogen_results_path
        % group_basename = 'Base';
    % else
        [~, group_basename, ~] = fileparts(app.result_group_path);
    % end
    dest_group_dir = fullfile(dest_path, group_basename);
    mkdir(dest_group_dir);
    copyfile(fullfile(source_group_dir, 'result_list.mat'), dest_group_dir);
    virtual_result_file = fullfile(source_group_dir, 'virtual_results.mat');
    if isfile(virtual_result_file)
        copyfile(virtual_result_file, dest_group_dir);
    end

    num_results = length(app.results);
    for i = 1 : num_results
        waitbar(double(i) / double(num_results + 1), wb, sprintf("Copying files"));
        app.export_result(app.results{i}, dest_group_dir);
    end
    close(wb);
    figure(app.MainFigure);
end
