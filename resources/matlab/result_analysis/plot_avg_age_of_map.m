function plot_avg_age_of_map(app)
    if ~isfield(app.stat, 'archive_age')
        msgbox("Current result doesn't have age information built into stat. Rebuild to plot");
        return
    end
    fig = figure();
    fig.Position(2) = 300; % bottom position
    sgtitle(sprintf("%s - Average Age of Map", app.result_displayname), 'Interpreter', 'none');
    hold on
    plot(app.stat.archive_age, 'DisplayName', 'Avg age of archive');
    plot(app.stat.elite_archive_age, 'DisplayName', 'Avg age of top 10');
    % plot(app.stat.clean_archive_age, 'DisplayName', 'Avg age of clean archive');
    plot(app.stat.clean_elite_archive_age, 'DisplayName', 'Avg age of clean top 10');
    hold off
    xlabel('Generations');
    ylabel('Age');
    legend('Interpreter', 'none', 'Location', 'SouthEast');
end
