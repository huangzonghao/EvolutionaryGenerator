function generate_paper_plot2(app)
    if isempty(app.UserInputFileListBox.Value)
        msgbox('Select a result to generate fitness trajectory');
        return
    end

    fig = figure('Position', [500, 500, 600, 300], 'NextPlot', 'add');

    result = app.results{app.UserInputFileListBox.Value(1)};
    hold on;
    plot(result.fitness(1,:), 'LineWidth', 3) % ground
    plot(result.fitness(2,:), 'LineWidth', 3) % sine
    plot(result.fitness(3,:), 'LineWidth', 3) % valley
    xlabel('Iteration', 'FontName', 'Times New Roman', 'FontSize', 15);
    ylabel('Fitness', 'FontName', 'Times New Roman', 'FontSize', 15);
    legend('Ground', 'Sine', 'Valley', 'FontName', 'Times New Roman', 'FontSize', 15, 'Location', 'best');
    box on

    if ~isempty(app.PaperPlotSaveNameField.Value)
        file_name = [result.user_id, '_fitness_traj.pdf'];
        exportgraphics(fig, file_name);
        msgbox(['Figure saved to ', file_name]);
    end
end
