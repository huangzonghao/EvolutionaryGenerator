function load_result(app, result_idx_to_load)
% extra results field after loaded:
%     stat: struct of the result stat
%     archive: cell array of gen archives
%              archive format: gen_id, id, f_id1, f_id2, fitness

    if length(app.results) == 0 || result_idx_to_load == -1
        return
    end

    for i = 1 : length(result_idx_to_load)
        result_idx = result_idx_to_load(i);
        if app.results{result_idx}.loaded
            continue
        end

        [app.results{result_idx}.stat, ~] = load_stat(app.results{result_idx}.path);
        archive_container = load(fullfile(app.results{result_idx}.path, 'archive.mat'));
        app.results{result_idx}.archive = archive_container.archive;

        app.results{result_idx}.loaded = true;
    end
end

function [stat, stat_loaded] = load_stat(result_dir)
    stat_loaded = false;
    stat = [];
    stat_file = fullfile(result_dir, 'stat.mat');
    if isfile(stat_file)
        % TODO: the behavior of this load is the reason that I can't merge this code into ui
        load(stat_file);
        stat_loaded = true;
    end
end
