function load_result(app)
    tmp_result_path = uigetdir(app.evogen_results_path, 'EvoGen Result Dir');
    figure(app.EvolutionaryRobogamiResultViewerUIFigure);
    if (tmp_result_path == 0) % User pressed cancel button
        return;
    end

    evo_xml = xml2struct(fullfile(tmp_result_path, app.params_filename));

    [~, app.result_basename, ~] = fileparts(tmp_result_path);
    app.result_path = tmp_result_path;
    app.evo_params.nb_gen_planned = str2double(evo_xml.boost_serialization{2}.EvoParams.nb_gen_.Text);
    app.evo_params.init_size = str2double(evo_xml.boost_serialization{2}.EvoParams.init_size_.Text);
    app.evo_params.gen_size = str2double(evo_xml.boost_serialization{2}.EvoParams.pop_size_.Text);
    app.evo_params.griddim_0 = str2double(evo_xml.boost_serialization{2}.EvoParams.grid_shape_.item{1}.Text);
    app.evo_params.griddim_1 = str2double(evo_xml.boost_serialization{2}.EvoParams.grid_shape_.item{2}.Text);
    app.evo_params.feature_description1 = evo_xml.boost_serialization{2}.EvoParams.feature_description_.item{1}.Text;
    app.evo_params.feature_description2 = evo_xml.boost_serialization{2}.EvoParams.feature_description_.item{2}.Text;

    statusfile_id = fopen(fullfile(tmp_result_path, 'status.txt'));
    status_info = cell2mat(textscan(statusfile_id, '%d/%d%*[^\n]'));
    fclose(statusfile_id);
    app.evo_params.nb_gen = status_info(1);
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
    app.result_to_compare = app.result_basename;
    [nickname, nickname_loaded] = load_nickname(tmp_result_path);
    if nickname_loaded
        app.NickNameSaveButton.Text = 'ReSave';
        app.result_displayname = [nickname, ' - (', app.result_basename, ')'];
        app.CompareListBox.Items = {nickname};
    else
        app.NickNameSaveButton.Text = 'Save';
        app.result_displayname = app.result_basename;
        app.CompareListBox.Items = {app.result_basename};
    end
    app.NickNameField.Value = nickname;
    app.ResultNameLabel.Text = app.result_displayname;

    app.current_gen = -1;
    load_gen(app, 0);
    app.result_loaded = true;
end
