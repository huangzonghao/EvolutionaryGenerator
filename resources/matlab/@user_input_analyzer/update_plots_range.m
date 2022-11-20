function update_plots_range(app, new_min, new_max)
    app.fitness_range(1) = min(new_min, app.fitness_range(1));
    app.fitness_range(2) = max(new_max, app.fitness_range(2));

    zlim(app.map_surf.axis, app.fitness_range);
    zlim(app.left_surf.axis, app.fitness_range);
    zlim(app.right_surf.axis, app.fitness_range);

    if isempty(app.map_heat.axis)
        app.heat_axes.map_heat.ColorLimits = app.fitness_range;
    end
    if isempty(app.left_heat.axis)
        app.heat_axes.left_heat.ColorLimits = app.fitness_range;
    end
    if isempty(app.right_heat.axis)
        app.heat_axes.right_heat.ColorLimits = app.fitness_range;
    end
end
