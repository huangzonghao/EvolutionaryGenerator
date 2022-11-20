function update_plots_range(app, new_min, new_max)
    ref = app.main_ref_plot;

    app.fitness_range(1) = min(new_min, app.fitness_range(1));
    app.fitness_range(2) = max(new_max, app.fitness_range(2));

    zlim(ref.map_surf.ax, app.fitness_range);
    zlim(ref.left_surf.ax, app.fitness_range);
    zlim(ref.right_surf.ax, app.fitness_range);

    ref.map_heat.ColorLimits = app.fitness_range;
    ref.left_heat.ColorLimits = app.fitness_range;
    ref.right_heat.ColorLimits = app.fitness_range;

    app.main_ref_plot = ref;
end
