function stat_plot(stat, evo_params, start_gen, end_gen)

    start_gen = max(start_gen, 0);
    end_gen = min(end_gen, evo_params.nb_gen);

    figure();
    sgtitle(evo_params.result_basename, 'Interpreter', 'none');

    subplot(2, 1, 1);
    hold on;
    p1 = plot(start_gen : end_gen, stat.archive_fits(start_gen + 1 : end_gen + 1), 'b');
    plot(start_gen: end_gen, stat.elite_archive_fits(start_gen + 1 : end_gen + 1), 'r');
    plot(start_gen : end_gen, stat.population_fits(start_gen + 1 : end_gen + 1), 'g');
    hold off;
    title('Fitness');
    xlabel('generation');
    ylabel('fitness');
    legend('archive mean', 'top 10% archive mean', 'pop mean', 'Location', 'NorthWest');

    subplot(2, 1, 2);
    p2 = plot(start_gen : end_gen, stat.coverage(start_gen + 1: end_gen + 1), 'b');
    title('Coverage');
    ylim([0 1]);
    xlabel('generation');
    ylabel('coverage');
end
