function load_existing_result(app)
    results_path = fullfile(app.workspace_dir, 'Results');
    result = {};
    % The windows back slash would casue js reading error in matlab, when reading
    % the info of an existing job file.
    tmp_path = uigetdir(results_path, 'Select result to load');
    tmp_path(strfind(tmp_path,'\'))='/';
    result.path = tmp_path;
    if result.path == 0
        return
    end

    % Check if the select path is a valid result
    if ~isdir(fullfile(result.path, 'dumps')) || ...
       ~isdir(fullfile(result.path, 'gridmaps')) || ...
       ~isdir(fullfile(result.path, 'robots')) || ...
       ~isfile(fullfile(result.path, 'evo_params.xml')) || ...
       ~isfile(fullfile(result.path, 'sim_params.xml')) || ...
       ~isfile(fullfile(result.path, 'status.txt'))

        msgbox('The selected folder is not a valid result to resume/continue');
        return
    end

    % now load the basic information of the results, especially evo_params
    result.evo_params = load_evo_params(result.path);
    % result.evo_params.nb_gen % the number of generations actually done
    % result.evo_params.nb_gen_planned % the number of generations planned
    result.num_dim = length(result.evo_params.grid_dim);
    grid_dim_str = '';
    for i = 1 : result.num_dim
        grid_dim_str = strcat(grid_dim_str, num2str(result.evo_params.grid_dim(i)), 'x');
    end
    result.grid_dim_str = grid_dim_str(1:end-1);

    % Load name
    [~, result.basename, ~] = fileparts(result.path);
    [result.name, nickname_loaded] = load_nickname(result.path);
    if ~nickname_loaded
        result.name = result.basename;
    end

    % Now format the label
    app.LoadedResultDetailLabel.Text = ...
        sprintf(['Name: %s\n', ...
                 'Folder: %s\n', ...
                 '# of Gen Finished:\n', ...
                 '\t%d/%d\n', ...
                 'Map Dimension: %d\n', ...
                 'Map size: %s\n'],...
                result.name, result.basename, ...
                result.evo_params.nb_gen, result.evo_params.nb_gen_planned, ...
                result.num_dim, result.grid_dim_str);

    app.result_loaded = result;
    figure(app.MainFigure);
end

function evo_params = load_evo_params(result_path)
    evo_xml = xml2struct(fullfile(result_path, 'evo_params.xml'));
    evo_params.nb_gen_planned = str2double(evo_xml.boost_serialization{2}.EvoParams.nb_gen_.Text);
    evo_params.init_size = str2double(evo_xml.boost_serialization{2}.EvoParams.init_size_.Text);
    evo_params.gen_size = str2double(evo_xml.boost_serialization{2}.EvoParams.pop_size_.Text);
    evo_params.grid_dim = [];
    for i = 1 : length(evo_xml.boost_serialization{2}.EvoParams.grid_shape_.item)
        evo_params.grid_dim(i) = str2double(evo_xml.boost_serialization{2}.EvoParams.grid_shape_.item{i}.Text);
    end
    evo_params.feature_description = "";
    for i = 1 : length(evo_xml.boost_serialization{2}.EvoParams.feature_description_.item)
        evo_params.feature_description(i) = evo_xml.boost_serialization{2}.EvoParams.feature_description_.item{i}.Text;
    end

    statusfile_id = fopen(fullfile(result_path, 'status.txt'));
    status_info = cell2mat(textscan(statusfile_id, '%d/%d%*[^\n]'));
    fclose(statusfile_id);
    evo_params.nb_gen = status_info(1);
end

function [nickname, success] = load_nickname(result_path)
    success = false;
    nickname = "";
    if isfile(fullfile(result_path, 'name.txt'))
        fid = fopen(fullfile(result_path, 'name.txt'));
        nickname = fscanf(fid, '%s');
        fclose(fid);
        success = true;
    end
end
