function sensitivity_analysis_init(app)
    if (ispc)
        app.simulator_name = strcat(app.simulator_basename, '.exe');
        app.generator_name = strcat(app.generator_basename, '.exe');
    else
        app.simulator_name = app.simulator_basename;
        app.generator_name = app.generator_basename;
    end

    app.SanitizeArchiveCheckBox.Value = false;

    % init ui assets
    app.plot_handles.gen_plot = {};
    app.plot_handles.fitness_compare = {};

    refresh_result_list(app);
end
