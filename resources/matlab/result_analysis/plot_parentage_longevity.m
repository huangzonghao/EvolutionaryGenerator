function plot_parentage_longevity(app)
    figure();
    x = app.stat.robot_parentage(:);
    y = app.stat.robot_longevity(:);
    selection = (y ~= 0);
    scatter(x(selection), y(selection), 'filled');
end
