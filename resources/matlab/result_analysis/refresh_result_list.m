function refresh_result_list(app, varargin)
% results field:
%     id: internal index of the result
%     path: full path to result dir
%     basename: basename of result dir
%     name: nickname or basename (when nickname not available)
%     loaded: whether the result has been fully loaded

    params = inputParser;
    params.CaseSensitive = false;
    params.addParameter('ForceUpdate', false, @(x) islogical(x));
    params.parse(varargin{:});
    force_update =  params.Results.ForceUpdate;

    if isempty(app.result_group_path)
        app.result_group_path = app.evogen_results_path;
        group_basename = 'Base';
    else
        [~, group_basename, ~] = fileparts(app.result_group_path);
    end
        result_dir = app.result_group_path;

    result_list_path = fullfile(app.result_group_path, 'result_list.mat');
    results = {};

    if ~force_update && isfile(result_list_path)
        results_file = load(result_list_path);
        results = results_file.results;
        % check the validity of the loaded results file
        if isempty(results) || ~isdir(results{1}.path)
            force_update = true;
        end
    end

    if force_update % refresh result entries
        names = string.empty;
        dirs = dir(result_dir);
        for i = 1 : length(dirs)
            tmp_path = fullfile(dirs(i).folder, dirs(i).name);
            if (~dirs(i).isdir || ~verify_result_dir(tmp_path))
                continue;
            end
            [~, basename, ~] = fileparts(tmp_path);
            new_result.isgroup = false;
            new_result.basename = basename;
            new_result.name = basename;
            [nickname, nickname_loaded] = load_nickname(tmp_path);
            if nickname_loaded
                new_result.name = nickname;
            end
            new_result.path = tmp_path;
            new_result.loaded = false;

            names(end+1) = string(new_result.name);
            results{end+1} = new_result;
        end

        [~, sort_order] = sort(names);
        results = results(sort_order);

        for i = 1 : length(results)
            results{i}.id = i;
        end

        save(result_list_path, 'results', '-v7.3');
    end

    app.results = results;
    app.current_result = {};

    app.ResultsListBox.Items = {};
    app.ResultsListBox.ItemsData = [];
    for i = 1 : length(results)
        app.ResultsListBox.Items{i} = get_result_list_string(app, i);
        app.ResultsListBox.ItemsData{i} = i;
    end
    app.ResultGroupLabel.Text = [group_basename, ' (', num2str(length(results)), ')'];

    load_virtual_results(app);
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
