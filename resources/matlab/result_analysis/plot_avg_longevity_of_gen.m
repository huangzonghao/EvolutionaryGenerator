function plot_avg_longevity_of_gen(app)
    % Plot the average lifetime of robots of the same generation
    if isempty(app.current_result) || isempty(app.current_result.stat)
        return
    end
    result = app.current_result;

    fig = figure('outerposition',[560, 90, 800, 900]);
    if result.plot_to_file
        fig.Visible = 'off';
    end

    sgtitle(sprintf("%s - Longevity of Generations", result.name), 'Interpreter', 'none');
    ph = subplot(2,1,1);
    plot(ph, mean(result.stat.robot_longevity), 'DisplayName', 'Avg longevity of generation');
    xlabel(ph, 'Generations');
    ylabel(ph, 'Longetivy');
    legend(ph, 'Interpreter', 'none');

    ph = subplot(2,1,2);
    plot(ph, max(result.stat.robot_longevity), 'DisplayName', 'Best longevity of generation');
    xlabel(ph, 'Generations');
    ylabel(ph, 'Longetivy');
    legend(ph, 'Interpreter', 'none');

    if result.plot_to_file
        for i_format = 1 : length(result.plot_format)
            saveas(fig, fullfile(result.plot_dir, ['avg_longevity_of_gen_', result.name, '.', result.plot_format{i_format}]));
        end
        close(fig);
    end
end
