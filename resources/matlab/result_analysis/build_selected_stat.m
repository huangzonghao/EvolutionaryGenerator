function build_selected_stat(app)
    for i = 1 : length(app.ResultsListBox.Value)
        result_path = app.results{app.ResultsListBox.Value{i}}.path;
        evo_params = load_evo_params(result_path);
        build_stat(result_path, evo_params, [], false);
    end
    refresh_result_list(app);
end
