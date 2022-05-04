function generate_paper_plot2(app)
% The figure for box plots of different setups of the same environemnt.
    if isempty(app.targets_to_compare)
        msgbox('Select at least one virtual result to generate the paper plot');
        return
    end
    num_virtual_results = length(app.targets_to_compare);
    for i = 1 : num_virtual_results
        if ~app.targets_to_compare{i}.isgroup
            msgbox('Must be virtual result');
            return
        end
    end

    fig = figure('Position', [100, 100, 600, 600]);
    if ~isempty(app.CompPlotNameField.Value)
        sgtitle(fig, app.CompPlotNameField.Value, 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 14);
    end
    % Subplot handles
    p = {};

    for i = 1 : 4
        p{i} = subplot(2, 2, i);
    end

    % Final QD-Score
    qd_score_mat = [];
    global_performance_mat = [];
    reliability_mat = [];
    for i_virtual = 1 : num_virtual_results
        virtual_result = app.virtual_results{app.targets_to_compare{i_virtual}.id};
        num_results = virtual_result.num_results;
        qd_column = zeros(num_results, 1);
        global_performance_column = zeros(num_results, 1);
        reliability_column = zeros(num_results, 1);

        for i_result = 1 : num_results
            % get the qd score for each result
            result = load_target_result(app, false, virtual_result.ids(i_result));

            qd_column(i_result) = result.stat.qd_score(end);
            global_performance_column(i_result) = result.stat.best_fits(end);

            current_gen_archive = result.archive{result.evo_params.nb_gen};
            x = current_gen_archive(:, 3) + 1;
            y = current_gen_archive(:, 4) + 1;
            fitness = current_gen_archive(:, 5);
            griddim = [result.evo_params.griddim_0, result.evo_params.griddim_1];
            archive_map = -Inf(griddim);
            % sanitize the second dimension (here griddim(1) gives the size of first dimension)
            fitness(sub2ind(size(archive_map), 1:griddim(1), ones(1, griddim(1)))) = 0.1 * rand(griddim(1), 1) + fitness(sub2ind(size(archive_map), 1:griddim(1), 1 + ones(1, griddim(1))));
            archive_map(sub2ind(size(archive_map), x, y)) = fitness;
            reliability_column(i_result) = sum(sum(archive_map ./ virtual_result.benchmark_archive)) / length(archive_map(:));
        end
        qd_score_mat = [qd_score_mat qd_column];
        global_performance_mat = [global_performance_mat global_performance_column / virtual_result.benchmark_best_fit];
        reliability_mat = [reliability_mat reliability_column];
    end

    boxplot(p{1}, qd_score_mat, 'Labels', {'H0', 'H5', 'H15', 'H25', 'H30'}, 'BoxStyle', 'filled');
    title(p{1}, 'QD-Score', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);

    boxplot(p{2}, global_performance_mat, 'Labels', {'H0', 'H5', 'H15', 'H25', 'H30'}, 'BoxStyle', 'filled');
    title(p{2}, 'Global Performance', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);

    boxplot(p{3}, reliability_mat, 'Labels', {'H0', 'H5', 'H15', 'H25', 'H30'}, 'BoxStyle', 'filled');
    title(p{3}, 'Reliabilitiy', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);

    boxplot(p{4}, reliability_mat, 'Labels', {'H0', 'H5', 'H15', 'H25', 'H30'}, 'BoxStyle', 'filled');
    title(p{4}, 'Precision', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);

    plot_height = p{1}.Position(3);
    plot_width = p{1}.Position(4);
    p{1}.Position(2) = p{2}.Position(2);
    for i = 1 : 4
        p{i}.Position(3) = plot_height;
        p{i}.Position(4) = plot_width;
    end

    % Save
    if ~isempty(app.CompPlotNameField.Value)
        exportgraphics(fig, [app.CompPlotNameField.Value '_box.pdf']);
    end
end
