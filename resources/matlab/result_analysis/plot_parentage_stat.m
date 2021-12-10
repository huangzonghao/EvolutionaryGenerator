function plot_parentage_stat(app)
    if isempty(app.current_result) || isempty(app.current_result.stat)
        return
    end
    result = app.current_result;
    if ~result.stat.has_parentage
        msgbox(sprintf("%s has no parentage information", result.name));
        return
    end

    num_rows = 1;
    num_cols = 2;
    fig = figure();
    sgtitle(sprintf("%s - Parentage Statistics", result.name), 'Interpreter', 'none');
    fig.Position(2) = 300; % bottom position
    fig.Position(3) = 800; % width

    % Parentage vs Generations
    grid_x = 1; grid_y = 1;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x);
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    plot(ph, result.stat.population_parentage, 'DisplayName', 'Avg per robot of each generation');
    plot(ph, result.stat.archive_parentage, 'DisplayName', 'Avg per robots in archive');
    plot(ph, result.stat.archive_parentage_over_map, 'DisplayName', 'Avg per bin in archive');
    xlabel(ph, 'Generations');
    ylabel(ph, 'Parentage');
    legend(ph, 'Interpreter', 'none', 'Location', 'best');

    % Fitness vs Generations
    grid_x = 1; grid_y = 2;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x);
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    plot(ph, result.stat.pop_hp_fitness, 'DisplayName', 'high parentage pop');
    plot(ph, result.stat.pop_lp_fitness, 'DisplayName', 'low parentage pop');
    plot(ph, result.stat.top15_hp_fitness, 'DisplayName', 'top 15 hp of all time');
    plot(ph, result.stat.top15_lp_fitness, 'DisplayName', 'top 15 lp of all time');
    xlabel(ph, 'Generations');
    ylabel(ph, 'Fitness');
    legend(ph, 'Interpreter', 'none', 'Location', 'best');
end
