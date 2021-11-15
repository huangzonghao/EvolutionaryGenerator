function load_result(app)
    if length(app.result_paths) == 0
        return
    end
    tmp_result_path = app.result_paths(app.ResultsListBox.Value{1});

    [~, app.result_basename, ~] = fileparts(tmp_result_path);
    app.result_path = tmp_result_path;
    app.evo_params = load_evo_params(tmp_result_path);
    [app.stat, app.stat_loaded] = load_stat(tmp_result_path);
    if app.stat_loaded
        app.BuildStatButton.Text = 'RebuildStat';
    else
        app.BuildStatButton.Text = 'BuildStat';
    end

    app.ResultInfoTextLabel.Text = ...
        sprintf(['# of Gen Finished: %d/%d\n', ...
                 'Progress: %.2f%%\n', ...
                 'Init size: %d\n', ...
                 'Pop size: %d\n', ...
                 'Map size: %dx%d\n'],...
                app.evo_params.nb_gen, app.evo_params.nb_gen_planned, ...
                double(app.evo_params.nb_gen) / app.evo_params.nb_gen_planned * 100, ...
                app.evo_params.init_size, ...
                app.evo_params.gen_size, ...
                app.evo_params.griddim_0, app.evo_params.griddim_1);

    app.StatStartGenField.Value = num2str(0);
    app.StatEndGenField.Value = num2str(app.evo_params.nb_gen);
    app.result_to_compare = [];
    app.CompareListBox.Items = {};
    app.result_to_compare(end + 1) = app.result_basename;
    app.result_displayname = app.result_basename;
    [nickname, nickname_loaded] = load_nickname(tmp_result_path);
    if nickname_loaded
        app.NickNameSaveButton.Text = 'ReSave';
        app.CompareListBox.Items{end + 1} = nickname;
    else
        app.NickNameSaveButton.Text = 'Save';
        app.CompareListBox.Items{end + 1} = convertStringsToChars(app.result_basename);
    end
    app.CompareListBox.ItemsData(end + 1) = length(app.result_to_compare);
    app.NickNameField.Value = nickname;
    app.ResultNameLabel.Text = app.result_displayname;

    app.current_gen = -1;
    load_gen(app, 0);
    app.result_loaded = true;
end
