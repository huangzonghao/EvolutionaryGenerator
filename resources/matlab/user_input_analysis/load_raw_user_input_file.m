function user_id = load_raw_user_input_file(app, input_file)
    %% Input file : the stem file name

    % First check if the file has been loaded before
    user_id = strrep(input_file, '.json', '');
    for i = 1 : length(app.results)
        if strcmp(app.results{i}.user_id, user_id);
            % disp('Same file already loaded. Exit without loading');
            return
        end
    end

    fid = fopen(fullfile(app.user_input_dir, input_file));
    jsobj = jsondecode(fscanf(fid, '%c', inf));
    fclose(fid);

    % Result Structure
    % env : the order of environments
    % fitness : num_env x num_ver (env in order of app.default_env_order)
    % feature : num_env x num_ver x 2 (env in order of app.default_env_order)
    % feature_description : string array containing the feature descriptions
    tmp_result.internal_id = length(app.results) + 1;
    user_id = jsobj.user_id;
    tmp_result.user_id = user_id;
    for i = 1 : length(jsobj.feature_description)
        tmp_result.feature_description(i) = string(jsobj.feature_description{i});
    end
    % TODO: find a way to automatically figure out the number of fields here (# of %s)
    env_cells = textscan(jsobj.env_string, '%s%s%s', 'Delimiter', ',');
    tmp_result.num_env = length(env_cells);
    num_ver = length(fieldnames(jsobj.designs.('ground')));

    % for the following matrices, assuming all env has same number of versions,
    % and matlab could handle this gracefully even if they don't
    tmp_result.fitness = zeros(tmp_result.num_env, num_ver);
    tmp_result.feature = zeros(tmp_result.num_env, num_ver, 2);
    for i = 1 : tmp_result.num_env
        env = string(env_cells{i});
        tmp_result.envs(i) = env;
    end

    % Store the data in the order of app.default_env_order
    for i = 1 : length(app.default_env_order)
        env_alt_name = strrep(app.default_env_order(i), '.', '_');
        if ~isfield(jsobj.designs, env_alt_name)
            fprintf('Missing env %s in %s\n', env_alt_name, user_id);
            continue
        end

        for j = 1 : length(fieldnames(jsobj.designs.(env_alt_name)))
            ver_name = strcat('x', num2str(j - 1));
            tmp_result.fitness(i, j) = jsobj.designs.(env_alt_name).(ver_name).fitness;
            tmp_result.feature(i, j, 1) = jsobj.designs.(env_alt_name).(ver_name).feature(1);
            tmp_result.feature(i, j, 2) = jsobj.designs.(env_alt_name).(ver_name).feature(2);
            tmp_result.gene{i,j} = jsobj.designs.(env_alt_name).(ver_name).gene;
        end
    end

    tmp_result.internal_id = length(app.results) + 1;
    app.results{end+1} = tmp_result;

    if isempty(app.default_feature_description)
        app.default_feature_description = tmp_result.feature_description;
    end
end
