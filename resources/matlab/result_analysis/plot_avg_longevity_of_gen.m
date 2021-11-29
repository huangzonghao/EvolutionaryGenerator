function plot_avg_longevity_of_gen(app)
    % Plot the average lifetime of robots of the same generation
    if ~isfield(app.stat, 'robot_longevity')
        msgbox("Current result doesn't have longevity information built into stat. Rebuild to plot");
        return
    end

    figure('outerposition',[560, 90, 800, 900]);
    sgtitle(sprintf("%s - Longevity of Generations", app.result_displayname), 'Interpreter', 'none');
    subplot(2,1,1);
    plot(mean(app.stat.robot_longevity), 'DisplayName', 'Avg longevity of generation');
    xlabel('Generations');
    ylabel('Longetivy');
    legend('Interpreter', 'none');

    subplot(2,1,2);
    plot(max(app.stat.robot_longevity), 'DisplayName', 'Best longevity of generation');
    xlabel('Generations');
    ylabel('Longetivy');
    legend('Interpreter', 'none');
end
