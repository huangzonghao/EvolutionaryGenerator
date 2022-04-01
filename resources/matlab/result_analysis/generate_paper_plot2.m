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

    fig = figure();
    if ~isempty(app.PaperPlot2NameField.Value)
        sgtitle(fig, app.PaperPlot2NameField.Value);
    end
    p1 = subplot(2, 2, 1);
    p2 = subplot(2, 2, 2);
    p3 = subplot(2, 2, 3);
    p4 = subplot(2, 2, 4);

    title(p3, 'Global Reality');
    title(p4, 'Global Precision');

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
            result = app.results{virtual_result.ids(i_result)};
            if ~result.loaded
                load_result(app, result.id);
                result = app.results{result.id};
            end

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

    boxplot(p1, qd_score_mat, 'Labels', {'H0', 'H5', 'H15', 'H25', 'H30'}, 'BoxStyle', 'filled');
    title(p1, 'QD-Score');
    ylabel(p1, 'QD-Score');

    boxplot(p2, global_performance_mat, 'Labels', {'H0', 'H5', 'H15', 'H25', 'H30'}, 'BoxStyle', 'filled');
    title(p2, 'Global Performance');

    boxplot(p3, reliability_mat, 'Labels', {'H0', 'H5', 'H15', 'H25', 'H30'}, 'BoxStyle', 'filled');
    title(p3, 'Reliabilitiy');

    boxplot(p4, reliability_mat, 'Labels', {'H0', 'H5', 'H15', 'H25', 'H30'}, 'BoxStyle', 'filled');
    title(p4, 'Precision');
end
