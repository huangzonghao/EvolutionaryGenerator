function refresh_raw_user_input_list(app)
    app.ListBox.Items = {};
    app.ListBox.ItemsData = [];
    app.results_enabled = [];

    dirs = dir(app.user_input_dir);
    counter = 1;
    for i = 1 : length(dirs)
        if (dirs(i).isdir || ~contains(dirs(i).name, digitsPattern(6) + '.json'))
            continue;
        end
        user_id = load_raw_user_input_file(app, dirs(i).name);
        app.ListBox.ItemsData(end + 1) = counter;
        app.results_enabled = [app.results_enabled; zeros(1, app.results{counter}.num_env)];
        counter = counter + 1;
    end

    update_listbox_text(app);

    app.auto_refresh_selected_list_on_next_enabled_update = true;
end
