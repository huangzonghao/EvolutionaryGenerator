function result_analysis_init(app)
    if (ispc)
        app.simulator_name = strcat(app.simulator_basename, '.exe');
        app.generator_name = strcat(app.generator_basename, '.exe');
    else
        app.simulator_name = app.simulator_basename;
        app.generator_name = app.generator_basename;
    end

    app.compare_plot_config.plot_to_file = false;

    % init ui assets
    app.GenStepField.Value = num2str(app.gen_step);
    app.TTestOptionDropDown.Items{1} = 'All Robots';
    app.TTestOptionDropDown.Items{2} = 'Result Stats';
    for i = 1 : length(app.TTestOptionDropDown.Items)
        app.TTestOptionDropDown.ItemsData(i) = i;
    end
    app.TTestOptionDropDown.Value = 1;

    app.SimTimeEditField.Value = 30;

    refresh_result_list(app);
end
