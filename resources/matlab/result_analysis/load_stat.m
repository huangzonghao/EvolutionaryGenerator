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
