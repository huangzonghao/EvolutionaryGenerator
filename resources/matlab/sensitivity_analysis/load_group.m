function load_group(app)
    app.result_group_path = uigetdir(app.evogen_results_path, 'EvoGen Result Group Dir');
    if app.result_group_path == 0
        return
    end
    figure(app.MainFigure);
    refresh_result_list(app);
end
