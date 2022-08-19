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

    sigstar_groups = {[1, 2], [1, 3], [1, 4], [1, 5], [2, 3], [2, 4], [2, 5], [3, 4], [3, 5], [4, 5]};
    fig = figure('Position', [100, 100, 1900, 600]);
    if ~isempty(app.CompPlotNameField.Value)
        sgtitle(fig, app.CompPlotNameField.Value, 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 14);
    end
    % Subplot handles
    % p = {};
    pn = panel(fig);
    pn.pack(1, 3);
    pn.select('all');

    % for i = 1 : 4
    for i = 1 : 3
        % p{i} = subplot(1, 3, i);
        p{i} = pn(1,i).axis;
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
            grid_dim = result.evo_params.grid_dim;
            archive_map = -Inf(grid_dim);
            % sanitize the second dimension (here grid_dim(1) gives the size of first dimension)
            fitness(sub2ind(size(archive_map), 1:grid_dim(1), ones(1, grid_dim(1)))) = 0.1 * rand(grid_dim(1), 1) + fitness(sub2ind(size(archive_map), 1:grid_dim(1), 1 + ones(1, grid_dim(1))));
            archive_map(sub2ind(size(archive_map), x, y)) = fitness;
            reliability_column(i_result) = sum(sum(archive_map ./ virtual_result.benchmark_archive)) / length(archive_map(:));
        end
        qd_score_mat = [qd_score_mat qd_column];
        global_performance_mat = [global_performance_mat global_performance_column / virtual_result.benchmark_best_fit];
        reliability_mat = [reliability_mat reliability_column];
    end

    p_qdscore = [];
    p_globalperformance = [];
    p_reliability = [];
    for i = 1 : 4
        for j = i + 1 : 5
            [p_qdscore(end+1), ~] = ranksum(qd_score_mat(:,i), qd_score_mat(:,j));
            [p_globalperformance(end+1), ~] = ranksum(global_performance_mat(:,i), global_performance_mat(:,j));
            [p_reliability(end+1), ~] = ranksum(reliability_mat(:,i), reliability_mat(:,j));
        end
    end

    boxplot(p{1}, qd_score_mat, 'Labels', {'H0', 'H5', 'H15', 'H25', 'H30'});
    title(p{1}, 'QD-Score', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);
    ylabel(p{1}, 'QD-Score', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);
    axes(p{1});
    sigstar(sigstar_groups, p_qdscore);

    boxplot(p{2}, global_performance_mat, 'Labels', {'H0', 'H5', 'H15', 'H25', 'H30'});
    title(p{2}, 'Global Performance', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);
    ylabel(p{2}, 'Global Performance', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);
    axes(p{2});
    sigstar(sigstar_groups, p_globalperformance);

    boxplot(p{3}, reliability_mat, 'Labels', {'H0', 'H5', 'H15', 'H25', 'H30'});
    title(p{3}, 'Reliabilitiy / Precision', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);
    ylabel(p{3}, 'Reliabilitiy / Precision', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);
    axes(p{3});
    sigstar(sigstar_groups, p_reliability);

    % boxplot(p{4}, reliability_mat, 'Labels', {'H0', 'H5', 'H15', 'H25', 'H30'}, 'BoxStyle', 'filled');
    % title(p{4}, 'Precision', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);
    % ylabel(p{4}, 'Precision', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);

    % plot_height = p{1}.Position(3);
    % plot_width = p{1}.Position(4);
    % p{1}.Position(2) = p{2}.Position(2);
    % for i = 1 : 4
    for i = 1 : 3
        % p{i}.Position(3) = plot_height;
        % p{i}.Position(4) = plot_width;
    end

    % Save
    if ~isempty(app.CompPlotNameField.Value)
        exportgraphics(fig, [app.CompPlotNameField.Value '_box.pdf']);
    end
end
