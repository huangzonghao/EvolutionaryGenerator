function plot_group_stat(app)
    if isempty(app.CompareListBox.Value)
        msgbox('Select a group result');
        return
    end
    do_plot = false;
    for i = 1 : length(app.CompareListBox.Value)
        result = app.results_to_compare{app.CompareListBox.Value(i)};
        if result.isgroup
            do_plot = true;
            break
        end
    end
    if ~do_plot
        msgbox('Select a group result');
        return
    end

    figure();
    ph = subplot(1,1,1);

    pop_hp_fitness = [];
    pop_lp_fitness = [];
    top15_hp_fitness = [];
    top15_lp_fitness = [];
    for i = 1 : length(result.result_full_paths)
        [tmp_stat, tmp_stat_loaded] = load_stat(result.result_full_paths(i));
        if (tmp_stat_loaded)
            if tmp_stat.has_parentage
                pop_hp_fitness(end + 1, :) = tmp_stat.pop_hp_fitness;
                pop_lp_fitness(end + 1, :) = tmp_stat.pop_lp_fitness;
                top15_hp_fitness(end + 1, :) = tmp_stat.top15_hp_fitness;
                top15_lp_fitness(end + 1, :) = tmp_stat.top15_lp_fitness;
            end
        end
    end
    plot_colors = 'brcmgk';
    shadedErrorBar(ph, [], pop_hp_fitness, {@mean, @std}, 'Color', plot_colors(1), 'DisplayName', 'pop_hp_fitness');
    shadedErrorBar(ph, [], pop_lp_fitness, {@mean, @std}, 'Color', plot_colors(2), 'DisplayName', 'pop_lp_fitness');
    shadedErrorBar(ph, [], top15_hp_fitness, {@mean, @std}, 'Color', plot_colors(3), 'DisplayName', 'top15_hp_fitness');
    shadedErrorBar(ph, [], top15_lp_fitness, {@mean, @std}, 'Color', plot_colors(4), 'DisplayName', 'top15_lp_fitness');
    legend(ph, 'Interpreter', 'none', 'Location', 'SouthEast');
end
