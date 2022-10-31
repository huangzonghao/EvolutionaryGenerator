function plot_from_dropdown(app)
    switch app.PlotSelectionDropDown.Value
    case 1 % Statistics
        plot_result_stat(app);
    case 2 % Bin Updates
        plot_bin_updates(app);
    case 3 % Parentage Stat
        plot_parentage_stat(app);
    case 4 % Parentage Plots
        plot_parentage_related(app);
    case 5 % Avg Age of Map
        plot_avg_age_of_map(app);
    case 6 % Longevity of Gen
        plot_avg_longevity_of_gen(app);
    case 7 % Parentage Tree
        plot_parentage_trace(app);
    case 8 % Compare Fitness
        compare_different_version_fitness(app);
    end
end
