function select_result(app, mode)
% extra field in app.current_result
%     plot_to_file: bool telling if the plots of this result should go to a file
%     mode: prev, user, next

    if isempty(app.results)
        msgbox('Load a result group first');
        return
    end

    result_id = 1;
    if mode == 'prev'
        if ~isempty(app.current_result)
            result_id = app.current_result.id - 1;
            if result_id < 1
                msgbox('Already at the first result');
                return
            end
        end
    elseif mode == 'next'
        if ~isempty(app.current_result)
            result_id = app.current_result.id + 1;
            if result_id > length(app.results)
                msgbox('Already at the last result');
                return
            end
        end
    else
        if length(app.ResultsListBox.Value) == 0
            msgbox('Select a result in the result explorer');
            return
        end
        % Select the first of the mulitple select
        result_id = app.ResultsListBox.Value{1};
    end

    result = load_target_result(app, false, result_id);
    app.ResultsListBox.Value = {result_id};

    num_dim = length(result.evo_params.grid_dim);
    grid_dim_str = '';
    for i = 1 : num_dim
        grid_dim_str = strcat(grid_dim_str, num2str(result.evo_params.grid_dim(i)), 'x');
    end
    app.ResultInfoTextLabel.Text = ...
        sprintf(['# of Gen Finished:\n', ...
                 '\t%d/%d\n', ...
                 'Progress: %.2f%%\n', ...
                 'Init size: %d\n', ...
                 'Pop size: %d\n', ...
                 'Map Dimension: %d\n', ...
                 'Map size: %s\n'],...
                result.evo_params.nb_gen, result.evo_params.nb_gen_planned, ...
                double(result.evo_params.nb_gen) / result.evo_params.nb_gen_planned * 100, ...
                result.evo_params.init_size, ...
                result.evo_params.gen_size, ...
                num_dim, ...
                grid_dim_str(1:end-1));

    app.StatStartGenField.Value = num2str(0);
    app.StatEndGenField.Value = num2str(result.evo_params.nb_gen);
    app.NickNameField.Value = result.name;
    app.ResultNameLabel.Text = result.name;

    app.current_result = result;
    app.current_result.plot_to_file = false;
    app.current_result.gen = -1;

    % Set up the feature dropdown
    for i = 1 : num_dim
        app.Feature1DropDown.Items{i} = result.evo_params.feature_description{i};
        app.Feature2DropDown.Items{i} = result.evo_params.feature_description{i};
    end
    app.Feature1DropDown.ItemsData = 1 : num_dim;
    app.Feature2DropDown.ItemsData = 1 : num_dim;
    app.Feature1DropDown.Value = 1;
    app.Feature2DropDown.Value = 2;
    load_gen(app, str2double(app.GenIDField.Value));
end
