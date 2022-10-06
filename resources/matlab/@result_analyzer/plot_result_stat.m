function plot_result_stat(app)
    if isempty(app.current_result)
        return
    end
    result = app.current_result;
    if isempty(result.stat)
        if ~result.plot_to_file
            msgbox('Build Stat first');
        end
        return
    end

    stat = result.stat;
    start_gen = str2double(app.StatStartGenField.Value);
    if start_gen < 0
        start_gen = 0;
        app.StatStartGenField.Value = num2str(0);
    end
    end_gen = str2double(app.StatEndGenField.Value);
    if end_gen > result.evo_params.nb_gen
        end_gen = result.evo_params.nb_gen;
        app.StatEndGenField.Value = num2str(end_gen);
    end

    num_subplots = 4;

    start_gen = max(start_gen, 0);
    end_gen = min(end_gen, length(stat.archive_fits) - 1); % stat contains gen 0

    fig = figure('units','normalized','outerposition',[.05 .05 .9 .9]);
    if result.plot_to_file
        fig.Visible = 'off';
    end

    sgtitle(sprintf("%s - Statistics", result.name), 'Interpreter', 'none');

    % Fitness Plot
    subplot(num_subplots, 1, 1);
    hold on;
    p1 = plot(start_gen : end_gen, stat.archive_fits(start_gen + 1 : end_gen + 1), 'LineWidth', 2, 'DisplayName', 'Archive Mean');
    plot(start_gen: end_gen, stat.elite_archive_fits(start_gen + 1 : end_gen + 1), 'LineWidth', 2, 'DisplayName', 'Top 10% Archive Mean');
    plot(start_gen : end_gen, stat.population_fits(start_gen + 1 : end_gen + 1), 'LineWidth', 2, 'DisplayName', 'Population Mean');
    plot(start_gen : end_gen, stat.best_fits(start_gen + 1 : end_gen + 1), 'LineWidth', 2, 'DisplayName', 'Best of Gen');
    if isfield(stat, 'visual_best_fits')
        plot(start_gen : end_gen, stat.visual_best_fits(start_gen + 1 : end_gen + 1), 'LineWidth', 2, 'DisplayName', 'Best of Gen - Visual');
    end
    hold off;
    title('Fitness');
    xlabel('generation');
    ylabel('fitness');
    legend('Location', 'best');

    % Change in Archive Fitness
    subplot(num_subplots, 1, 2);
    change_to_prev_gen = [];
    for i = start_gen + 2 : end_gen + 1 % (start_gen + 1) is the data index for start_gen
        change_to_prev_gen(end + 1) = stat.archive_fits(i) - stat.archive_fits(i - 1);
    end
    p2 = plot(start_gen + 1 : end_gen, change_to_prev_gen);
    title('Change in Fitness');
    % ylim([0 1]);
    xlabel('generation');
    ylabel('diff fitness');

    if (end_gen - start_gen > 10)
        hold on;
        change_to_prev_10gen = [];
        prev_10_avg = mean(stat.archive_fits(start_gen + 1 : start_gen + 10));
        for i = start_gen + 11 : end_gen + 1
            change_to_prev_10gen(end + 1) = stat.archive_fits(i) - prev_10_avg;
            prev_10_avg = prev_10_avg + 0.1 * (stat.archive_fits(i) - stat.archive_fits(i - 10));
        end
        plot(start_gen + 10 : end_gen, change_to_prev_10gen, 'r');
        hold off;
        legend('Diff to prev gen', 'Diff to avg of prev 10 gen', 'Location', 'best');
    else
        legend('Diff to prev gen', 'Location', 'best');
    end

    % Change in Archive Elites Fitness
    subplot(num_subplots, 1, 3);
    change_to_prev_gen = [];
    for i = start_gen + 2 : end_gen + 1 % (start_gen + 1) is the data index for start_gen
        change_to_prev_gen(end + 1) = stat.elite_archive_fits(i) - stat.elite_archive_fits(i - 1);
    end
    p3 = plot(start_gen + 1 : end_gen, change_to_prev_gen);
    title('Change in Elite Fitness');
    % ylim([0 1]);
    xlabel('generation');
    ylabel('diff fitness');

    if (end_gen - start_gen > 10)
        hold on;
        change_to_prev_10gen = [];
        prev_10_avg = mean(stat.elite_archive_fits(start_gen + 1 : start_gen + 10));
        for i = start_gen + 11 : end_gen + 1
            change_to_prev_10gen(end + 1) = stat.elite_archive_fits(i) - prev_10_avg;
            prev_10_avg = prev_10_avg + 0.1 * (stat.elite_archive_fits(i) - stat.elite_archive_fits(i - 10));
        end
        plot(start_gen + 10 : end_gen, change_to_prev_10gen, 'r');
        hold off;
        legend('Diff to prev gen', 'Diff to avg of prev 10 gen', 'Location', 'best');
    else
        legend('Diff to prev gen', 'Location', 'best');
    end

    % Coverage Plot
    subplot(num_subplots, 1, 4);
    p3 = plot(start_gen : end_gen, stat.coverage(start_gen + 1 : end_gen + 1), 'b');
    hold on;
    plot(start_gen : end_gen, ones(1, end_gen - start_gen + 1) * 0.5,'Color','k','LineStyle','--');
    hold off;
    title('Coverage');
    ylim([0 1]);
    xlabel('generation');
    ylabel('coverage');

    if result.plot_to_file
        for i_format = 1 : length(result.plot_format)
            saveas(fig, fullfile(result.plot_dir, ['result_stat_', result.name, '.', result.plot_format{i_format}]));
        end
        close(fig);
    end
end
