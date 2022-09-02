function load_gen(app, gen_to_load)
    if isempty(app.current_result)
        return
    end
    gen_to_load = min(max(gen_to_load, 0), app.current_result.evo_params.nb_gen);
    if (gen_to_load == app.current_gen)
        return
    end
    app.current_gen = gen_to_load;
    app.GenIDField.Value = num2str(app.current_gen);
    plot_gen_all(app);
    if isfield(app.plot_handles.fitness_compare, 'fig') && ...
       ishandle(app.plot_handles.fitness_compare.fig)
        compare_different_version_fitness(app);
    end
end