function refresh_result_list(app)
    if isempty(app.result_group_path)
        result_dir = app.evogen_results_path;
        app.ResultGroupLabel.Text = 'Base';
    else
        result_dir = app.result_group_path;
        [~, app.ResultGroupLabel.Text, ~] = fileparts(app.result_group_path);
    end

    app.ResultsListBox.Items = {};
    app.ResultsListBox.ItemsData = [];
    app.result_paths = string.empty;

    dirs = dir(result_dir);
    counter = 1;
    for i = 1 : length(dirs)
        tmp_path = fullfile(dirs(i).folder, dirs(i).name);
        if (~dirs(i).isdir || ~verify_result_dir(tmp_path))
            continue;
        end
        app.result_paths(end+1) = tmp_path;
        app.ResultsListBox.Items{end+1} = get_result_list_string(app, length(app.result_paths));
        app.ResultsListBox.ItemsData{end+1} = length(app.result_paths);
    end
end

function ret_str = get_result_list_string(app, result_idx)
    ret_str = '';
    result_path = app.result_paths(result_idx);
    % first check if the statistics has been built
    if ~isfile(fullfile(result_path, 'stat.mat'));
        ret_str = "* ";
    end
    [nickname, nickname_loaded] = load_nickname(result_path);
    if nickname_loaded
        ret_str = strcat(ret_str, nickname);
    else
        [~, basename, ~] = fileparts(result_path);
        ret_str = strcat(ret_str, basename);
    end
    ret_str = convertStringsToChars(ret_str);
end

function result_is_valid = verify_result_dir(dir_path)
    result_is_valid = false;
    if isdir(fullfile(dir_path, 'gridmaps')) && ...
       isdir(fullfile(dir_path, 'gridstats')) && ...
       isdir(fullfile(dir_path, 'robots')) && ...
       isfile(fullfile(dir_path, 'evo_params.xml')) && ...
       isfile(fullfile(dir_path, 'status.txt'))

        result_is_valid = true;
    end
end
