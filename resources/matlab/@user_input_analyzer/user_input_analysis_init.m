function user_input_analysis_init(app, evogen_exe_path, evogen_user_input_path, evogen_results_path)
    movegui(app.MainFigure, 'center');

    if (ispc)
        app.simulator_name = strcat(app.simulator_basename, '.exe');
    else
        app.simulator_name = app.simulator_basename;
    end

    app.user_input_dir = evogen_user_input_path;
    app.training_results_dir = evogen_results_path;
    app.evogen_exe_path = evogen_exe_path;

    % TODO: Sync view among surf plots
    % camera_link = linkprop([app.map_surf.axis, app.stat_bar.axis, app.left_surf.axis, app.right_surf.axis], {'CameraUpVector', 'CameraPosition', 'CameraTarget'});
    % setappdata(app.MainFigure, 'StoreTheLink', camera_link);

    % init params
    app.archive_map = nan(app.map_dim_0, app.map_dim_1);
    app.map_stat = zeros(app.map_dim_0, app.map_dim_1, length(app.default_env_order));
    app.ScreenshotNameField.Value = "Screenshot.png";
    app.OutputBagNameField.Value = string.empty;
    app.NumRandomField.Value = "0";
end
