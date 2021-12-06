function refresh_result_list(app)
    if isempty(app.result_group_path)
        result_dir = app.evogen_results_path;
        group_basename = 'Base';
    else
        result_dir = app.result_group_path;
        [~, group_basename, ~] = fileparts(app.result_group_path);
    end

    app.ResultsListBox.Items = {};
    app.ResultsListBox.ItemsData = [];
    app.results = {};
    names = string.empty;

    dirs = dir(result_dir);
    for i = 1 : length(dirs)
        tmp_path = fullfile(dirs(i).folder, dirs(i).name);
        if (~dirs(i).isdir || ~verify_result_dir(tmp_path))
            continue;
        end
        [~, basename, ~] = fileparts(tmp_path);
        new_result.basename = basename;
        new_result.name = basename;
        [nickname, nickname_loaded] = load_nickname(tmp_path);
        if nickname_loaded
            new_result.name = nickname;
        end
        new_result.path = tmp_path;

        names(end+1) = string(new_result.name);
        app.results{end+1} = new_result;
    end

    [~, sort_order] = sort(names);
    app.results = app.results(sort_order);

    for i = 1 : length(app.results)
        app.ResultsListBox.Items{i} = get_result_list_string(app, i);
        app.ResultsListBox.ItemsData{i} = i;
    end

    app.ResultGroupLabel.Text = [group_basename, ' (', num2str(length(app.results)), ')'];
end

function ret_str = get_result_list_string(app, result_idx)
    result = app.results{result_idx};
    ret_str = '';
    % first check if the statistics has been built
    if ~isfile(fullfile(result.path, 'stat.mat'));
        ret_str = "* ";
    end
    ret_str = strcat(ret_str, result.name);
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
