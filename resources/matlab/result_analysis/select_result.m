function select_result(app)
% extra field in app.current_result
%     plot_to_file: bool telling if the plots of this result should go to a file

    if length(app.ResultsListBox.Value) == 0
        msgbox('Select a result in the result explorer');
        return
    end

    % Select the first of the mulitple select
    result = load_target_result(app, false, app.ResultsListBox.Value{1});

    app.ResultInfoTextLabel.Text = ...
        sprintf(['# of Gen Finished: %d/%d\n', ...
                 'Progress: %.2f%%\n', ...
                 'Init size: %d\n', ...
                 'Pop size: %d\n', ...
                 'Map size: %dx%d\n'],...
                result.evo_params.nb_gen, result.evo_params.nb_gen_planned, ...
                double(result.evo_params.nb_gen) / result.evo_params.nb_gen_planned * 100, ...
                result.evo_params.init_size, ...
                result.evo_params.gen_size, ...
                result.evo_params.griddim_0, result.evo_params.griddim_1);

    app.StatStartGenField.Value = num2str(0);
    app.StatEndGenField.Value = num2str(result.evo_params.nb_gen);
    app.NickNameField.Value = result.name;
    app.ResultNameLabel.Text = result.name;

    app.current_result = result;
    app.current_result.plot_to_file = false;
    app.current_gen = -1;

    load_gen(app, 0);
end
