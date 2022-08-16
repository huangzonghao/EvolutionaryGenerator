function plot_parentage_stat(app)
    if isempty(app.current_result) || isempty(app.current_result.stat)
        return
    end
    result = app.current_result;
    if ~result.stat.has_parentage
        if ~result.plot_to_file
            msgbox(sprintf("%s has no parentage information", result.name));
        end
        return
    end

    num_rows = 1;
    num_cols = 2;
    fig = figure();
    if result.plot_to_file
        fig.Visible = 'off';
    end
    fig.Position(2) = 300; % bottom position
    fig.Position(3) = 800; % width

    sgtitle(sprintf("%s - Parentage Statistics", result.name), 'Interpreter', 'none');
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

    if result.plot_to_file
        for i_format = 1 : length(result.plot_format)
            saveas(fig, fullfile(result.plot_dir, ['parentage_stat_', result.name, '.', result.plot_format{i_format}]));
        end
        close(fig);
    end
end
