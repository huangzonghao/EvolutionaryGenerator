function export_archive_map(app)
    if isempty(app.current_result)
        msgbox("Error: no result loaded");
        return
    end
    if ~isfield(app.current_result, 'current_archive_map') || isempty(app.current_result.current_archive_map)
        msgbox("Error: no archive map loaded");
    end
    result = app.current_result;
    archive_map = result.current_archive_map;
    root_dir = fullfile(app.result_group_path, 'plots');
    if ~isfolder(root_dir)
        mkdir(root_dir);
    end
    output_filename = fullfile(root_dir, [result.name, '_gen_', num2str(app.current_result.gen), '_archive_map.mat']);
    % save(output_filename, 'archive_map', '-v7.3');
    msgbox(sprintf("Archive map data file write to %s", output_filename));

    figure();
    archive_heat = heatmap(archive_map);
    archive_heat.NodeChildren(3).YDir='normal';
    archive_heat.MissingDataLabel = 'Nan';
    archive_heat.MissingDataColor = [1, 1, 1];
    colormap(archive_heat, 'jet');
end
