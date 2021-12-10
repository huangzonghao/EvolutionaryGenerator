function plot_avg_longevity_of_gen(app)
    % Plot the average lifetime of robots of the same generation
    if isempty(app.current_result) || isempty(app.current_result.stat)
        return
    end
    result = app.current_result;
    if ~isfield(result.stat, 'robot_longevity')
        msgbox("Current result doesn't have longevity information built into stat. Rebuild to plot");
        return
    end

    figure('outerposition',[560, 90, 800, 900]);
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
end
