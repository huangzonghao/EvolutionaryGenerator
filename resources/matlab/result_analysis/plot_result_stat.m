function plot_result_stat(app)
    if (~app.stat_loaded)
        msgbox('Build Stat first');
        return;
    end
    stat = app.stat;
    start_gen = str2double(app.StatStartGenField.Value);
    end_gen = str2double(app.StatEndGenField.Value);

    num_subplots = 4;

    start_gen = max(start_gen, 0);
    end_gen = min(end_gen, length(stat.archive_fits) - 1); % stat contains gen 0

    figure('units','normalized','outerposition',[.05 .05 .9 .9]);
    sgtitle(app.result_displayname, 'Interpreter', 'none');

    % Fitness Plot
    subplot(num_subplots, 1, 1);
    hold on;
    p1 = plot(start_gen : end_gen, stat.archive_fits(start_gen + 1 : end_gen + 1), 'b');
    plot(start_gen: end_gen, stat.elite_archive_fits(start_gen + 1 : end_gen + 1), 'r');
    plot(start_gen : end_gen, stat.population_fits(start_gen + 1 : end_gen + 1), 'g');
    hold off;
    title('Fitness');
    xlabel('generation');
    ylabel('fitness');
    legend('archive mean', 'top 10% archive mean', 'pop mean', 'Location', 'NorthWest');

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
        legend('Diff to prev gen', 'Diff to avg of prev 10 gen', 'Location', 'NorthEast');
    else
        legend('Diff to prev gen', 'Location', 'NorthEast');
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
        legend('Diff to prev gen', 'Diff to avg of prev 10 gen', 'Location', 'NorthEast');
    else
        legend('Diff to prev gen', 'Location', 'NorthEast');
    end

    % Coverage Plot
    subplot(num_subplots, 1, 4);
    p3 = plot(start_gen : end_gen, stat.coverage(start_gen + 1 : end_gen + 1), 'b');
    title('Coverage');
    ylim([0 1]);
    xlabel('generation');
    ylabel('coverage');
end
