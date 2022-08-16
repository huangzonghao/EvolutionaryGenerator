function generate_video_fitness_plot(app)
    if length(app.targets_to_compare) == 0 || length(app.targets_to_compare) > 5
        msgbox('Add at most 5 single results to comparison target to generate video fitness plot');
        return
    end

    plot_colors = [  1,   0,   0;
                   0.7, 0.4,   0;
                     0,   1,   0;
                     0,   0,   1];

    if app.targets_to_compare{1}.isgroup
        fig = generate_for_virtual_results(app, plot_colors);
    else
        fig = generate_for_single_results(app, plot_colors);
    end
end

function mean_fig = generate_for_virtual_results(app, plot_colors)

    legend_entries = {};
    legend_handles = [];
    mean_fig = figure('Position', [100, 100, 960, 360]);
    mean_ax = axes(mean_fig, 'NextPlot', 'add');
    mean_ax.Position = [0.02 0.07 0.96 0.9];
    mean_ax.XLim = [-50, 2050];
    best_fig = figure('Position', [100, 100, 960, 360]);
    best_ax = axes(best_fig, 'NextPlot', 'add');
    best_ax.Position = [0.02 0.07 0.96 0.9];
    best_ax.XLim = [-50, 2050];
    for i = 1 : length(app.targets_to_compare)
        plot_color = plot_colors(rem(i - 1, size(plot_colors, 1)) + 1, :);
        result = load_target_result(app, true, app.targets_to_compare{i}.id);

        best_fits = [];
        clean_archive_fits = [];
        for i_virtual_result = 1 : result.num_results
            child_result = load_target_result(app, false, result.ids(i_virtual_result));
            best_fits(end + 1, :) = child_result.stat.best_fits;
            clean_archive_fits(end + 1, :) = child_result.stat.clean_archive_fits;
        end
        shadedErrorBar(best_ax, [], best_fits, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
        h = shadedErrorBar(mean_ax, [], clean_archive_fits, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
        this_name = result.name;
        this_name(1:strfind(this_name, '_')) = [];
        legend_entries{end+1} = ['H' this_name];
        legend_handles(end+1) = h.mainLine;
    end
    leg = legend(legend_handles, legend_entries, 'location','southeast','orientation','horizontal', 'fontsize', 25);
    leg.ItemTokenSize = [20, 18];

    plot(mean_ax, [app.VideoGenIDField.Value, app.VideoGenIDField.Value], mean_ax.YLim, 'k', 'LineWidth', 2, 'DisplayName', 'Gen');
    plot(best_ax, [app.VideoGenIDField.Value, app.VideoGenIDField.Value], best_ax.YLim, 'k', 'LineWidth', 2, 'DisplayName', 'Gen');

    if ~isempty(app.CompPlotNameField.Value)
        % print(fig, [app.CompPlotNameField.Value '_compare.pdf'],'-dpdf','-painters');
        exportgraphics(best_fig, [app.CompPlotNameField.Value '_group_video_fitness_', num2str(app.VideoGenIDField.Value), '_best_.png']);
        exportgraphics(mean_fig, [app.CompPlotNameField.Value '_group_video_fitness_', num2str(app.VideoGenIDField.Value), '_mean_.png']);
    end
end

function best_fig = generate_for_single_results(app, plot_colors)
    result_name = {'H0', 'H15', 'H25', 'H30'};
    gen_order = [0, 500, 1000, 1500, 2000];
    for i_gen = 1 : length(gen_order)
      gen = gen_order(i_gen);

      legend_entries = {};
      legend_handles = [];
      best_fig = figure('Position', [100, 100, 580, 540]);
      ax = axes(best_fig);
      ax.NextPlot = 'add';
      ax.XLim = [-50, 2050];
      ax.FontSize = 20;
      ax.FontName = 'Times New Roman';
      ax.XLabel.String = '\bf Iterations';
      ax.XLabel.FontSize = 25;
      ax.YLabel.String = '\bf Best Fitness';
      ax.YLabel.FontSize = 25;
      for i_target = 1 : length(app.targets_to_compare)
        plot_color = plot_colors(rem(i_target - 1, size(plot_colors, 1)) + 1, :);
        result = load_target_result(app, false, app.targets_to_compare{i_target}.id);
        h = plot(ax, result.stat.best_fits, 'Color', plot_color, 'LineWidth', 4);

        legend_entries{end+1} = result_name{i_target};
        legend_handles(end+1) = h;
      end
      plot(ax, [gen, gen], ax.YLim, 'k', 'LineWidth', 5, 'DisplayName', 'Gen');
      % leg = legend(legend_handles, legend_entries, 'location','southeast','orientation','vertical', 'fontsize', 15);
      % leg.ItemTokenSize = [20, 18];
      if ~isempty(app.CompPlotNameField.Value)
        % print(fig, [app.CompPlotNameField.Value '_compare.pdf'],'-dpdf','-painters');
        exportgraphics(best_fig, [app.CompPlotNameField.Value '_group_video_fitness_', num2str(gen), '_best_.png']);
      end
    end
end
