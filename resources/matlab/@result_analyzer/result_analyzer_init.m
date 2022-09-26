function result_analyzer_init(app)
    movegui(app.MainFigure, 'center');

    if (ispc)
        app.simulator_name = strcat(app.simulator_basename, '.exe');
        app.generator_name = strcat(app.generator_basename, '.exe');
    else
        app.simulator_name = app.simulator_basename;
        app.generator_name = app.generator_basename;
    end

    app.SanitizeArchiveCheckBox.Value = false;
    app.compare_plot_config.plot_to_file = false;

    % init ui assets
    app.GenStepField.Value = num2str(app.gen_step);
    app.TTestOptionDropDown.Items = ["All Robots", "result Stats"];
    app.TTestOptionDropDown.ItemsData = 1 : length(app.TTestOptionDropDown.Items);
    app.TTestOptionDropDown.Value = 1;

    app.GenIDField.Value = '0';
    app.SimTimeEditField.Value = 30;
    app.DumpRobotsCheckBox.Value = false;
    app.VideoGenIDField.Value = 0;
    app.VideoGenIDField.Limits = [0, 2000];

    app.plot_handles.gen_plot = {};
    app.plot_handles.fitness_compare = {};

    app.ReEvalTypeDropDown.Items = ["All", "Archive All", "Best of Gen"];
    app.ReEvalTypeDropDown.ItemsData = 1 : length(app.ReEvalTypeDropDown.Items);
    app.ReEvalTypeDropDown.Value = 1;

    if isfile('result_analyzer_meta_info.mat')
        meta_info_container = load('result_analyzer_meta_info.mat');
        meta_info = meta_info_container.meta_info;
    else
        meta_info = {};
        meta_info.results_path = app.evogen_results_path;
        save('result_analyzer_meta_info.mat', 'meta_info', '-v7.3');
    end
    app.meta_info = meta_info;

    refresh_result_list(app);
end
