function plot_longevity_vs_parentage(app)
    if ~isfield(app.stat, 'robot_parentage')
        msgbox('This result has no parentage information available');
        return
    end
    figure();
    x = app.stat.robot_parentage(:);
    y = app.stat.robot_longevity(:);
    selection = (y ~= 0);
    scatter(x(selection), y(selection), 'filled');
    xlabel('Parentage');
    ylabel('Longevity');
    title(sprintf("%s - Longevity vs Parentage", app.result_displayname), 'Interpreter', 'none');
end
