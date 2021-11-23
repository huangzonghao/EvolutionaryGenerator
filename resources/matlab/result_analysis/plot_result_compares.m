function plot_result_compares(app, do_clean_plot)
    num_subplots = 3;
    figure('units','normalized','outerposition',[.05 .05 .9 .9]);
    if ~isempty(app.CompPlotNameField.Value)
        tmp_title = app.CompPlotNameField.Value;
        if do_clean_plot
            tmp_title = strcat(tmp_title, '_Clean');
        end
        sgtitle(tmp_title, 'Interpreter', 'none');
    end
    p1 = subplot(num_subplots, 1, 1);
    hold on;
    if do_clean_plot
        title('Clean Fitness');
    else
        title('Fitness');
    end
    xlabel('generation');
    ylabel('fitness');
    p2 = subplot(num_subplots, 1, 2);
    hold on;
    if do_clean_plot
        title('Clean Elite Fitness');
    else
        title('Elite Fitness');
    end
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
            plot_color = plot_colors(rem(i, length(plot_colors)) + 1);
            if do_clean_plot
                plot(p1, stat.clean_archive_fits, 'DisplayName', legend_name);
                plot(p2, stat.clean_elite_archive_fits, 'DisplayName', legend_name);
            else
                plot(p1, stat.archive_fits, 'DisplayName', legend_name);
                plot(p2, stat.elite_archive_fits, 'DisplayName', legend_name);
            end
            plot(p3, stat.coverage, 'DisplayName', legend_name);
        end
    end
    if app.result_to_compare.length < 7
        legend(p1, 'Interpreter', 'none');
        legend(p2, 'Interpreter', 'none');
        legend(p3, 'Interpreter', 'none', 'Location', 'SouthEast');
    end

    % then plot

    % fitness over gen
    % elite fitness over gen
    % coverage over gen
end
