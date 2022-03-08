function refresh_raw_user_input_list(app)
    app.ListBox.Items = {};
    app.ListBox.ItemsData = [];
    app.results_enabled = [];
    app.results = {};

    dirs = dir(app.user_input_dir);
    counter = 1;
    for i = 1 : length(dirs)
        if (dirs(i).isdir || ~contains(dirs(i).name, digitsPattern(6) + '.json'))
            continue;
        end

        user_file = fullfile(app.user_input_dir, dirs(i).name);

        % First check if the file has been loaded before
        % TODO: better logic for checking
        user_id = strrep(user_file, '.json', '');
        loaded = false;
        for j = 1 : length(app.results)
            if strcmp(app.results{j}.user_id, user_id);
                loaded = true;
                break;
            end
        end
        if loaded
            continue;
        end
        new_user = load_raw_user_input_file(app, user_file);
        new_user.internal_id = counter;
        app.results{end+1} = new_user;
        if isempty(app.default_feature_description)
            app.default_feature_description = new_user.feature_description;
        end

        app.ListBox.ItemsData(end + 1) = counter;
        app.results_enabled = [app.results_enabled; zeros(1, app.results{counter}.num_env)];
        counter = counter + 1;
    end

    update_listbox_text(app);

    app.auto_refresh_selected_list_on_next_enabled_update = true;
end
