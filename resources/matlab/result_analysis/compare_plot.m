function compare_plot(result_dirs, parent_path)
    num_subplots = 3;
    figure('units','normalized','outerposition',[.05 .05 .9 .9]);
    p1 = subplot(num_subplots, 1, 1);
    hold on;
    title('Fitness');
    xlabel('generation');
    ylabel('fitness');
    p2 = subplot(num_subplots, 1, 2);
    hold on;
    title('Elite Fitness');
    xlabel('generation');
    ylabel('fitness');
    p3 = subplot(num_subplots, 1, 3);
    hold on;
    title('Coverage');
    xlabel('generation');
    ylabel('coverage');

    % get each plot a different color
    plot_colors = 'brcmgk';
    for i = 1 : result_dirs.length
    end

    % first load all stat
    for i = 1 : result_dirs.length
        result_path = fullfile(parent_path, result_dirs(i));
        [stat, stat_loaded] = load_stat(result_path);
        if (stat_loaded)
            [nickname, nickname_loaded] = load_nickname(result_path);
            if nickname_loaded
                legend_name = nickname;
            else
                legend_name = result_dirs(i);
            end
            plot_color = plot_colors(i);
            plot(p1, stat.archive_fits, 'DisplayName', legend_name);
            plot(p2, stat.elite_archive_fits, 'DisplayName', legend_name);
            plot(p3, stat.coverage, 'DisplayName', legend_name);
        end
    end
    legend(p1, 'Interpreter', 'none');
    legend(p2, 'Interpreter', 'none');
    legend(p3, 'Interpreter', 'none', 'Location', 'SouthEast');

    % then plot

    % fitness over gen
    % elite fitness over gen
    % coverage over gen
end
