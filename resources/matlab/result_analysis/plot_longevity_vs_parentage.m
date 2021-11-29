function plot_longevity_vs_parentage(app)
    figure();
    x = app.stat.robot_parentage(:);
    y = app.stat.robot_longevity(:);
    selection = (y ~= 0);
    scatter(x(selection), y(selection), 'filled');
    xlabel('Parentage');
    ylabel('Longevity');
    title(sprintf("%s - Longevity vs Parentage", app.result_displayname), 'Interpreter', 'none');
end
