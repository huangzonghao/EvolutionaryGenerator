function load_gen(app, gen_to_load)
    gen_to_load = min(max(gen_to_load, 0), app.evo_params.nb_gen);
    if (gen_to_load == app.current_gen)
        return
    end
    app.current_gen = gen_to_load;
    app.current_gen_archive = readmatrix(fullfile(app.result_path, strcat('/gridmaps/', num2str(app.current_gen), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
    app.GenIDField.Value = num2str(app.current_gen);
    plot_gen_all(app);
end
