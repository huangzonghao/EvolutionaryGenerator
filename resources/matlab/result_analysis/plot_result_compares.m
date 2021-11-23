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

    for i = 1 : length(app.results_to_compare)
        stat_loaded = false;
        result = app.results_to_compare{i};
        if ~result.isgroup
            [stat, stat_loaded] = load_stat(result.full_path);
        else % group
            stat.coverage = [];
            stat.archive_fits = [];
            stat.elite_archive_fits = [];
            stat.clean_archive_fits = [];
            stat.clean_elite_archive_fits = [];

            for i = 1 : length(result.result_full_paths)
                [tmp_stat, tmp_stat_loaded] = load_stat(result.result_full_paths(i));
                if (tmp_stat_loaded)
                    stat_loaded = true;
                    stat.coverage(end + 1, :) = tmp_stat.coverage;
                    stat.archive_fits(end + 1, :) = tmp_stat.archive_fits;
                    stat.elite_archive_fits(end + 1, :) = tmp_stat.elite_archive_fits;
                    stat.clean_archive_fits(end + 1, :) = tmp_stat.clean_archive_fits;
                    stat.clean_elite_archive_fits(end + 1, :) = tmp_stat.clean_elite_archive_fits;
                end
            end
            stat.coverage = mean(stat.coverage);
            stat.archive_fits = mean(stat.archive_fits);
            stat.elite_archive_fits = mean(stat.elite_archive_fits);
            stat.clean_archive_fits = mean(stat.clean_archive_fits);
            stat.clean_elite_archive_fits = mean(stat.clean_elite_archive_fits);
        end

        if (~stat_loaded)
            continue
        end

        legend_name = result.name;
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

    if length(app.results_to_compare) < 10
        legend(p1, 'Interpreter', 'none');
        legend(p2, 'Interpreter', 'none');
        legend(p3, 'Interpreter', 'none', 'Location', 'SouthEast');
    end

    hold off;
end
