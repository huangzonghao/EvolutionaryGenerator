function load_group(app)
    app.result_group_path = uigetdir(app.meta_info.results_path, 'EvoGen Result Group Dir');
    if app.result_group_path == 0
        return
    end

    [results_path, ~, ~] = fileparts(app.result_group_path);
    if ~strcmp(results_path, app.meta_info.results_path)
        app.meta_info.results_path = results_path;
        meta_info = app.meta_info;
        save('result_analyzer_meta_info.mat', 'meta_info', '-v7.3');
    end

    figure(app.MainFigure);
    refresh_result_list(app);
end
