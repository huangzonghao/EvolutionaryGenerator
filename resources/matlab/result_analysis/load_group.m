function load_group(app)
    app.result_group_path = uigetdir(app.evogen_results_path, 'EvoGen Result Group Dir');
    figure(app.MainFigure);
    refresh_result_list(app);
end
