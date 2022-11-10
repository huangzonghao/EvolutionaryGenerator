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
    qd_score_mat = {};
    global_performance_mat = {};
    reliability_mat = {};
    for i_virtual = 1 : num_virtual_results
        virtual_result = app.virtual_results{app.targets_to_compare{i_virtual}.id};
        num_results = virtual_result.num_results;
        qd_tmp = zeros(1, num_results);
        global_performance_tmp = zeros(1, num_results);
        reliability_tmp = zeros(1, num_results);

        for i_result = 1 : num_results
            % get the qd score for each result
            result = load_target_result(app, false, virtual_result.ids(i_result));

            qd_tmp(i_result) = result.stat.qd_score(end);
            global_performance_tmp(i_result) = result.stat.best_fits(end);

            current_gen_archive = result.archive{result.evo_params.nb_gen};
            if result.version < 2
                f_ids(:, 1) = current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
                f_ids(:, 2) = current_gen_archive(:, 4) + 1;
                fitness = current_gen_archive(:, 5);
            else
                f1_selection = 1;
                f2_selection = 2;
                f_ids(:, 1) = current_gen_archive(:, f1_selection + 3) + 1; % remember matlab index starts from 1
                f_ids(:, 2) = current_gen_archive(:, f2_selection + 3) + 1;
                fitness_all = current_gen_archive(:, 3);

                % Remove duplicates of (f_id1, f_id2) based on fitness -- reprojecting
                %     the multi-dimension grid map to a 2D map
                f_ids(:, 3) = fitness_all;
                f_ids(:, 4) = 1 : length(fitness_all);
                f_ids = sortrows(f_ids, 3, 'descend');
                [~, unik_ids, ~] = unique(f_ids(:, 1:2), 'rows', 'stable');
                f_ids = f_ids(unik_ids, :);
                fitness = f_ids(:, 3);
            end
            grid_dim = result.evo_params.grid_dim;
            archive_map = -Inf(grid_dim);
            % sanitize the second dimension (here grid_dim(1) gives the size of first dimension)
            fitness(sub2ind(size(archive_map), 1:grid_dim(1), ones(1, grid_dim(1)))) = 0.1 * rand(grid_dim(1), 1) + fitness(sub2ind(size(archive_map), 1:grid_dim(1), 1 + ones(1, grid_dim(1))));
            archive_map(sub2ind(size(archive_map), f_ids(:, 1), f_ids(:, 2))) = fitness;
            reliability_tmp(i_result) = sum(sum(archive_map ./ virtual_result.benchmark_archive)) / length(archive_map(:));
            f_ids = [];
        end
        qd_score_mat{i_virtual} = qd_tmp;
        global_performance_mat{i_virtual} = global_performance_tmp;
        reliability_mat{i_virtual} = reliability_tmp;
    end

    p_qdscore = [];
    p_globalperformance = [];
    p_reliability = [];
    for i = 1 : 4
        for j = i + 1 : 5
            [p_qdscore(end+1), ~] = ranksum(qd_score_mat{i}, qd_score_mat{j});
            [p_globalperformance(end+1), ~] = ranksum(global_performance_mat{i}, global_performance_mat{j});
            [p_reliability(end+1), ~] = ranksum(reliability_mat{i}, reliability_mat{j});
        end
    end

    qd_score_data = [];
    qd_score_group = [];
    global_performance_data = [];
    global_performance_group = [];
    reliability_data = [];
    reliability_group = [];
    for i = 1 : num_virtual_results
        qd_score_data = [qd_score_data qd_score_mat{i}];
        qd_score_group = [qd_score_group i * ones(size(qd_score_mat{i}))];
        global_performance_data = [global_performance_data global_performance_mat{i}];
        global_performance_group = [global_performance_group i * ones(size(global_performance_mat{i}))];
        reliability_data = [reliability_data reliability_mat{i}];
        reliability_group = [reliability_group i * ones(size(reliability_mat{i}))];
    end
    qd_score_data
    qd_score_group
    boxplot(p{1}, qd_score_data, qd_score_group, 'Labels', {'H0', 'H5', 'H15', 'H25', 'H30'});
    title(p{1}, 'QD-Score', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);
    ylabel(p{1}, 'QD-Score', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);
    axes(p{1});
    sigstar(sigstar_groups, p_qdscore);

    boxplot(p{2}, global_performance_data, global_performance_group, 'Labels', {'H0', 'H5', 'H15', 'H25', 'H30'});
    title(p{2}, 'Global Performance', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);
    ylabel(p{2}, 'Global Performance', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 11);
    axes(p{2});
    sigstar(sigstar_groups, p_globalperformance);

    boxplot(p{3}, reliability_data, reliability_group, 'Labels', {'H0', 'H5', 'H15', 'H25', 'H30'});
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
