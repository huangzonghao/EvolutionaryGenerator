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

    if need_to_save
        save(fullfile(result_path, 'stat.mat'), 'stat', '-v7.3');
    end
end
