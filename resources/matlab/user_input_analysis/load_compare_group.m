function load_compare_group(app)
    new_path = uigetdir(app.user_input_dir, 'EvoGen User Input Group Dir');
    if new_path == 0
        return
    end

    for i = 1 : length(app.results)
        compare_file = fullfile(new_path, [app.results{i}.user_id, '.json']);
        if ~isfile(compare_file)
            app.results{i}.compare = {};
        end

        app.results{i}.compare = load_raw_user_input_file(app, compare_file);
    end

    app.compare_group = true;
end
