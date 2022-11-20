function generate_paper_plot3(app)
    fig = figure('Position', [500, 500, 600, 300], 'NextPlot', 'add');
    ax = axes(fig);

    num_results = length(app.results);
    env1 = [];
    env2 = [];
    env3 = [];
    for i = 1 : num_results
        result = app.results{i};
        if length(result.fitness(1,:)) ~= 11
            continue
        end
        env1(i,:) = result.fitness(1,:);
        env2(i,:) = result.fitness(2,:);
        env3(i,:) = result.fitness(3,:);
    end

    plot_colors = [1, 0, 0;
                   1, .6, 0;
                   0, .75, 0;
                   0, .75, .75;
                   0, 0, 1];

    shadedErrorBar(ax, [], env1, {@mean, @std}, 'Color', plot_colors(1,:), 'DisplayName', 'Ground');
    shadedErrorBar(ax, [], env2, {@mean, @std}, 'Color', plot_colors(2,:), 'DisplayName', 'Sine');
    shadedErrorBar(ax, [], env3, {@mean, @std}, 'Color', plot_colors(3,:), 'DisplayName', 'Valley');
    xlabel('Iteration', 'FontName', 'Times New Roman', 'FontSize', 15);
    ylabel('Fitness', 'FontName', 'Times New Roman', 'FontSize', 15);
    legend('FontName', 'Times New Roman', 'FontSize', 15, 'Location', 'best');
    box on

    if ~isempty(app.PaperPlotSaveNameField.Value)
        file_name = [app.PaperPlotSaveNameField.Value, '.pdf'];
        exportgraphics(fig, file_name);
        msgbox(['Figure saved to ', file_name]);
    end
end
