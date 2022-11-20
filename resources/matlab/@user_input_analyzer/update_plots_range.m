function update_plots_range(app, new_min, new_max)
    ref = app.main_ref_plot;

    app.fitness_range(1) = min(new_min, app.fitness_range(1));
    app.fitness_range(2) = max(new_max, app.fitness_range(2));

    zlim(ref.map_surf.axis, app.fitness_range);
    zlim(ref.left_surf.axis, app.fitness_range);
    zlim(ref.right_surf.axis, app.fitness_range);

    if isempty(ref.map_heat.axis)
        ref.heat_axes.map_heat.ColorLimits = app.fitness_range;
    end
    if isempty(ref.left_heat.axis)
        ref.heat_axes.left_heat.ColorLimits = app.fitness_range;
    end
    if isempty(ref.right_heat.axis)
        ref.heat_axes.right_heat.ColorLimits = app.fitness_range;
    end

    app.main_ref_plot = ref;
end
