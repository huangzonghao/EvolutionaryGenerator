function plot_group_stat(app)
    if isempty(app.current_virtual_result)
        if isempty(app.VirtualResultsListBox.Value)
            msgbox('Select a virtual result');
            return
        end
        result = app.virtual_results{app.VirtualResultsListBox.Value(1)};
        result.plot_to_file = false;
    else
        result = app.current_virtual_result;
    end

    pop_hp_fitness = [];
    pop_lp_fitness = [];
    top15_hp_fitness = [];
    top15_lp_fitness = [];
    for i = 1 : result.num_results
        child_result = load_target_result(app, false, result.ids(i));
        if child_result.stat.has_parentage
            pop_hp_fitness(end + 1, :) = child_result.stat.pop_hp_fitness;
            pop_lp_fitness(end + 1, :) = child_result.stat.pop_lp_fitness;
            top15_hp_fitness(end + 1, :) = child_result.stat.top15_hp_fitness;
            top15_lp_fitness(end + 1, :) = child_result.stat.top15_lp_fitness;
        end
    end

    if ~isempty(pop_hp_fitness)
        fig = figure();
        if result.plot_to_file
            fig.Visible = 'off';
        end

        sgtitle([result.name, ' - High Parentage and Low Parentage Fitness'], 'Interpreter', 'none');
        ph = subplot(1,1,1);
        plot_colors = 'brcmgk';
        shadedErrorBar(ph, [], pop_hp_fitness, {@mean, @std}, 'Color', plot_colors(1), 'DisplayName', 'pop_hp_fitness');
        shadedErrorBar(ph, [], pop_lp_fitness, {@mean, @std}, 'Color', plot_colors(2), 'DisplayName', 'pop_lp_fitness');
        shadedErrorBar(ph, [], top15_hp_fitness, {@mean, @std}, 'Color', plot_colors(3), 'DisplayName', 'top15_hp_fitness');
        shadedErrorBar(ph, [], top15_lp_fitness, {@mean, @std}, 'Color', plot_colors(4), 'DisplayName', 'top15_lp_fitness');
        xlabel(ph, 'Generations');
        ylabel(ph, 'Fitness');
        legend(ph, 'Interpreter', 'none', 'Location', 'best');
        if result.plot_to_file
            for i_format = 1 : length(result.plot_format)
                saveas(fig, fullfile(result.plot_dir, ['hp_and_lp_fitness_', result.name, '.', result.plot_format{i_format}]));
            end
            close(fig);
        end
    end
end
