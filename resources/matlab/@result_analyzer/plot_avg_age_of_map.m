function plot_avg_age_of_map(app)
    if isempty(app.current_result) || isempty(app.current_result.stat)
        return
    end
    result = app.current_result;
    fig = figure();
    if result.plot_to_file
        fig.Visible = 'off';
    end
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

    if result.plot_to_file
        for i_format = 1 : length(result.plot_format)
            saveas(fig, fullfile(result.plot_dir, ['avg_age_of_map_', result.name, '.', result.plot_format{i_format}]));
        end
        close(fig);
    end
end
