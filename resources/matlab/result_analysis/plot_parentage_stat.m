function plot_parentage_stat(app)
    if ~app.stat.has_parentage
        return
    end
    fig = figure();
    fig.Position(2) = 300; % bottom position
    sgtitle(sprintf("%s - Parentage Statistics", app.result_displayname), 'Interpreter', 'none');
    plot(app.stat.population_parentage, 'DisplayName', 'Avg per robot of each generation');
    hold on
    plot(app.stat.archive_parentage, 'DisplayName', 'Avg per robots in archive');
    plot(app.stat.archive_parentage_over_map, 'DisplayName', 'Avg per bin in archive');
    hold off
    xlabel('Generations');
    ylabel('Percentage of User Inputs');
    legend('Interpreter', 'none', 'Location', 'SouthEast');
end
