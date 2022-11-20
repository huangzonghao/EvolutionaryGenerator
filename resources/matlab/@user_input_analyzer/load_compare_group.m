function load_compare_group(app)
    compare_group.path = uigetdir(app.user_input_dir, 'EvoGen User Input Group Dir');
    if compare_group.path == 0
        return
    end
    [~, compare_group.name, ~] = fileparts(compare_group.path);

    for i = 1 : length(app.results)
        compare_file = fullfile(compare_group.path, [app.results{i}.user_id, '.json']);
        if ~isfile(compare_file)
            app.results{i}.compare = {};
        end

        app.results{i}.compare = load_raw_user_input_file(app, compare_file);
    end

    app.UserCompareGroupNameLabel.Text = compare_group.name;
    figure(app.MainFigure);

    % TODO: store the compare group structure in the future if we need to use
    % it in a more complicated way.
    app.compare_group = true;
end
