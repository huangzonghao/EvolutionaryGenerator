function plot_age_of_bins(app)
    % plot how many generations since the bin was lastly updated
    if ~isfield(app.stat, 'archive_age')
        return
    end
    figure();
    hold on
    plot(app.stat.archive_age, 'DisplayName', 'Avg age of archive');
    plot(app.stat.elite_archive_age, 'DisplayName', 'Avg age of top 10');
    % plot(app.stat.clean_archive_age, 'DisplayName', 'Avg age of clean archive');
    plot(app.stat.clean_elite_archive_age, 'DisplayName', 'Avg age of clean top 10');
    hold off
    xlabel('Generations');
    ylabel('Age');
    legend('Interpreter', 'none');

end
