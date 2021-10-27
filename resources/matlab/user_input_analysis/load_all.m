function loda_all(app)
    app.ListBox.Items = {};
    app.ListBox.ItemsData = [];
    app.results_enabled = [];

    dirs = dir(app.user_input_dir);
    counter = 1;
    for i = 1 : length(dirs)
        if (dirs(i).isdir && ~contains(dirs(i).name, digitsPattern(6) + '.json'))
            continue;
        end
        user_id = load_result_file(app, dirs(i).name);
        app.ListBox.ItemsData(end + 1) = counter;
        app.results_enabled = [app.results_enabled; zeros(1, app.results{counter}.num_env)];
        counter = counter + 1;
    end

    update_listbox_text(app);
end