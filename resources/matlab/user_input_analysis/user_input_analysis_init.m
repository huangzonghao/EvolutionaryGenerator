function user_input_analysis_init(app, evogen_exe_path, evogen_user_input_path, evogen_results_path)
    if (ispc)
        app.simulator_name = strcat(app.simulator_basename, '.exe');
    else
        app.simulator_name = app.simulator_basename;
    end

    app.user_input_dir = evogen_user_input_path;
    app.training_results_dir = evogen_results_path;
    app.evogen_exe_path = evogen_exe_path;

    % camera_link = linkprop([app.MapViewerAxes, app.MapStatViewerAxes, app.RefLeftAxes, app.RefRightAxes], {'CameraUpVector', 'CameraPosition', 'CameraTarget'});
    % setappdata(app.MainFigure, 'StoreTheLink', camera_link);
    lim_link = linkprop([app.MapViewerAxes, app.RefLeftAxes, app.RefRightAxes], {'ZLim'});
    setappdata(app.MainFigure, 'StoreTheLink', lim_link);

    % init params
    app.archive_map = zeros(app.map_dim_0, app.map_dim_1);
    app.map_stat = zeros(app.map_dim_0, app.map_dim_1, length(app.default_env_order));
end
