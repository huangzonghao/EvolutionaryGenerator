function load_gen(app, gen_to_load)
    gen_to_load = min(max(gen_to_load, 0), app.evo_params.nb_gen);
    if (gen_to_load == app.current_gen)
        return
    end
    app.current_gen = gen_to_load;
    app.current_gen_archive = readmatrix(fullfile(app.result_path, strcat(app.archive_prefix, num2str(app.current_gen), app.archive_subfix)));
    app.GenIDField.Value = num2str(app.current_gen);
    plot_heatmap(app);
end
