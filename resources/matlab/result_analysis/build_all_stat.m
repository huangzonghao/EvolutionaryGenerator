function build_all_stat(app)
% go through all results of result_paths and build stats for every unbuilt ones
    if length(app.result_paths) == 0
        return
    end
    for i = 1 : length(app.result_paths)
        result_path = app.result_paths(i);
        if isfile(fullfile(result_path, 'stat.mat'));
            continue;
        end
        evo_params = load_evo_params(result_path);
        build_stat(result_path, evo_params, [], false);
    end
    refresh_result_list(app);
end
