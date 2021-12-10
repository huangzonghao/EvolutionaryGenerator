function plot_avg_age_of_map(app)
    if isempty(app.current_result) || isempty(app.current_result.stat)
        return
    end
    result = app.current_result;
    if ~isfield(result.stat, 'archive_age')
        msgbox("Current result doesn't have age information built into stat. Rebuild to plot");
        return
    end
    fig = figure();
    fig.Position(2) = 300; % bottom position
    ph = axes(fig, 'NextPlot', 'add');
    sgtitle(sprintf("%s - Average Age of Map", result.name), 'Interpreter', 'none');
    plot(ph, result.stat.archive_age, 'DisplayName', 'Avg age of archive');
    plot(ph, result.stat.elite_archive_age, 'DisplayName', 'Avg age of top 10');
    % plot(ph, result.stat.clean_archive_age, 'DisplayName', 'Avg age of clean archive');
    plot(ph, result.stat.clean_elite_archive_age, 'DisplayName', 'Avg age of clean top 10');
    xlabel(ph, 'Generations');
    ylabel(ph, 'Age');
    legend(ph, 'Interpreter', 'none', 'Location', 'SouthEast');
end
