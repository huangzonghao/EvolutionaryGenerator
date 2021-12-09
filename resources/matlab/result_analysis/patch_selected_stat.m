% This function patches the prebuilt .mat files with new variables
% Patching only makes sense when the new stat variables could take advantage of
% the existing results, otherwise we should simply update build_stat.m and then
% rebuild
function patch_selected_stat(app)
    wb = waitbar(0, 'Start patching', 'Name', 'Patching Results');
    wb.Children.Title.Interpreter = 'none';
    num_patches = length(app.ResultsListBox.Value);
    if num_patches == 0
        msgbox('Select results to patch');
    end
    for i = 1 : num_patches
        result = app.results{app.ResultsListBox.Value{i}};
        waitbar(double(i) / double(num_patches), wb, sprintf("Patching %s (%d / %d)", result.name, i, num_patches));
        patch_stat(result.path);
    end
    close(wb);
    refresh_result_list(app);
end

function patch_stat(result_path)
    % first load the existing stat, and then check and load the missed ones
    evo_params = load_evo_params(result_path);
    nb_gen = evo_params.nb_gen;
    [stat, stat_loaded] = load_stat(result_path);
    need_to_save = false;

    if ~stat_loaded
        msgbox(sprintf("No stat loaded in %s, build stat first", result_path));
        return
    end

    % Now check fields of stat and apply modifications appropriately
    % Add robot_fitness
    if ~isfield(stat, 'robot_fitness')
        robot_file = load(fullfile(result_path, 'robots.mat'));
        stat.robot_fitness = squeeze(robot_file.robots(:, 9, :));
        need_to_save = true;
    end

    % % Longevity Patch
    % archive_file = load(fullfile(result_path, 'archive.mat'));
    % prev_gen_archive = archive_file.archive{1};
    % for i = 1 : nb_gen % can't do the following to gen 0
        % curr_gen_archive =  archive_file.archive{i + 1};
        % age = double(i) * ones(size(curr_gen_archive, 1), 1) - curr_gen_archive(:, 1);
        % f_ids = curr_gen_archive(age == 0, 3:4);
        % prev_f_ids = prev_gen_archive(:, 3:4);
        % [~, dead_selection] = ismember(f_ids, prev_f_ids, 'rows');
        % dead_selection = dead_selection(dead_selection ~= 0);
        % dead_gen_ids = prev_gen_archive(dead_selection, 1) + 1;
        % dead_ids = prev_gen_archive(dead_selection, 2) + 1;
        % stat.robot_longevity(sub2ind(size(stat.robot_longevity), dead_ids, dead_gen_ids)) = double(i + 1) * ones(size(dead_gen_ids)) - dead_gen_ids;
        % if i == nb_gen
            % dead_gen_ids = curr_gen_archive(:, 1) + 1;
            % dead_ids = curr_gen_archive(:, 2) + 1;
            % stat.robot_longevity(sub2ind(size(stat.robot_longevity), dead_ids, dead_gen_ids)) = double(i + 2) * ones(size(dead_gen_ids)) - dead_gen_ids;
        % end
        % prev_gen_archive = curr_gen_archive;
    % end
    % need_to_save = true;

    % % Elite selection patch
    % archive_file = load(fullfile(result_path, 'archive.mat'));
    % stat.elite_robot_selection = false(evo_params.gen_size, nb_gen + 1); % entries of value 1 indicate the corresponding robot has made it to 10% of the archive map at some generation
    % for i = 0 : nb_gen
        % % gridmap format : gen_id, id, f_id1, f_id2, fitness
        % curr_gen_archive =  archive_file.archive{i + 1};
        % fitness = curr_gen_archive(:, 5);
        % [~, max10_idx] = maxk(fitness, ceil(length(fitness) * 0.1));
        % max10_gen_ids = curr_gen_archive(max10_idx, 1) + 1;
        % max10_ids = curr_gen_archive(max10_idx, 2) + 1;
        % stat.elite_robot_selection(sub2ind(size(stat.elite_robot_selection), max10_ids, max10_gen_ids)) = true;
    % end
    % need_to_save = true;

    if need_to_save
        save(fullfile(result_path, 'stat.mat'), 'stat', '-v7.3');
    end
end
