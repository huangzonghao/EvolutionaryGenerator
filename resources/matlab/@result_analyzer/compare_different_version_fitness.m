% Note: to run this function, name the two extra_stats.mat files to:
%     1) extra_stats.mat (unchanged)
%     2) extra_stats_2.mat
function compare_different_version_fitness(app)
    if isempty(app.current_result)
        msgbox('Select a result to compare different versions of fitness');
        return
    end

    result = app.current_result;
    if result.version != 1
        msgbox('Cannot compare different fitness, result version is not 1');
        return
    end
    current_gen = app.current_result.gen;
    grid_dim = result.evo_params.grid_dim;

    extra_stats_1_path = fullfile(result.path, 'extra_stats.mat');
    extra_stats_2_path = fullfile(result.path, 'extra_stats_2.mat');
    if ~isfile(extra_stats_1_path)
        msgbox('extra_stats_1 not found');
        return
    end
    if ~isfile(extra_stats_2_path)
        msgbox('extra_stats_2 not found');
        return
    end

    extra_stats_1_container = load(extra_stats_1_path);
    extra_stats{1} = extra_stats_1_container.extra_stats;
    extra_stats_2_container = load(extra_stats_2_path);
    extra_stats{2} = extra_stats_2_container.extra_stats;

    num_rows = 2;
    num_cols = 3;
    if ~isfield(app.plot_handles.fitness_compare, 'fig') || ...
       ~ishandle(app.plot_handles.fitness_compare.fig)

        app.plot_handles.fitness_compare.fig = figure();
        fig = app.plot_handles.fitness_compare.fig;
        fig.Units = 'normalized';
        fig.OuterPosition = [0, 0, 1, 1];
        p = panel(fig);
        p.marginright = 20;
        p.pack(num_rows, num_cols)
        % First create the plot
        titles = ["Training", "Re-evaluate 1", "Re-evaluate 2";
                  "Diff T - R1", "Diff T - R2", "Diff R1 - R2"];
        for i_row = 1 : num_rows
            for i_col = 1 : num_cols
                p(i_row, i_col).select();
                app.plot_handles.fitness_compare.p{i_row, i_col} = heatmap(zeros(grid_dim));
                app.plot_handles.fitness_compare.p{i_row, i_col}.NodeChildren(3).YDir='normal';
                app.plot_handles.fitness_compare.p{i_row, i_col}.Title = titles(i_row, i_col);
                app.plot_handles.fitness_compare.p{i_row, i_col}.MissingDataLabel = 'Nan';
                app.plot_handles.fitness_compare.p{i_row, i_col}.MissingDataColor = [1, 1, 1];
                colormap(app.plot_handles.fitness_compare.p{i_row, i_col}, 'jet');
            end
        end
        app.plot_handles.fitness_compare.p{1, 1}.YLabel = result.evo_params.feature_description(1);
        app.plot_handles.fitness_compare.p{2, 1}.YLabel = result.evo_params.feature_description(1);
        app.plot_handles.fitness_compare.p{2, 1}.XLabel = result.evo_params.feature_description(2);
        app.plot_handles.fitness_compare.p{2, 2}.XLabel = result.evo_params.feature_description(2);
        app.plot_handles.fitness_compare.p{2, 3}.XLabel = result.evo_params.feature_description(2);
    end

    % TODO: how to formulate the archive maps
    archive_map = nan(grid_dim);
    archive_map2 = nan(grid_dim);
    archive_map3 = nan(grid_dim);
    current_gen_archive = result.archive{current_gen + 1};
    x = current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
    y = current_gen_archive(:, 4) + 1;
    gen_ids = current_gen_archive(:, 1) + 1;
    robot_ids = current_gen_archive(:, 2) + 1;

    fitness = current_gen_archive(:, 5);
    fitness2_size = size(extra_stats{1}.fitness2);
    fitness2 = extra_stats{1}.fitness2(sub2ind(fitness2_size, gen_ids, robot_ids));
    fitness3 = extra_stats{2}.fitness2(sub2ind(fitness2_size, gen_ids, robot_ids));

    % if app.SanitizeArchiveCheckBox.Value == true
        % % sanitize the second dimension (here grid_dim(1) gives the size of first dimension)
        % fitness(sub2ind(size(archive_map), 1:grid_dim(1), ones(1, grid_dim(1)))) = 0.1 * rand(grid_dim(1), 1) + fitness(sub2ind(size(archive_map), 1:grid_dim(1), 1 + ones(1, grid_dim(1))));
        % fitness2(sub2ind(size(archive_map2), 1:grid_dim(1), ones(1, grid_dim(1)))) = 0.1 * rand(grid_dim(1), 1) + fitness(sub2ind(size(archive_map2), 1:grid_dim(1), 1 + ones(1, grid_dim(1))));
        % fitness3(sub2ind(size(archive_map3), 1:grid_dim(1), ones(1, grid_dim(1)))) = 0.1 * rand(grid_dim(1), 1) + fitness(sub2ind(size(archive_map3), 1:grid_dim(1), 1 + ones(1, grid_dim(1))));
    % end

    archive_map(sub2ind(size(archive_map), x, y)) = fitness;
    archive_map2(sub2ind(size(archive_map), x, y)) = fitness2;
    archive_map3(sub2ind(size(archive_map), x, y)) = fitness3;

    diff_1_2 = archive_map - archive_map2;
    diff_1_3 = archive_map - archive_map3;
    diff_2_3 = archive_map2 - archive_map3;

    app.plot_handles.fitness_compare.p{1, 1}.ColorData = archive_map;
    app.plot_handles.fitness_compare.p{1, 2}.ColorData = archive_map2;
    app.plot_handles.fitness_compare.p{1, 3}.ColorData = archive_map3;
    app.plot_handles.fitness_compare.p{2, 1}.ColorData = diff_1_2;
    app.plot_handles.fitness_compare.p{2, 2}.ColorData = diff_1_3;
    app.plot_handles.fitness_compare.p{2, 3}.ColorData = diff_2_3;

    c_min = Inf;
    c_max = -Inf;
    for i_row = 1 : num_rows
        for i_col = 1 : num_cols
            c_min = min([c_min, app.plot_handles.fitness_compare.p{i_row, i_col}.ColorLimits(1)]);
            c_max = max([c_max, app.plot_handles.fitness_compare.p{i_row, i_col}.ColorLimits(2)]);
        end
    end
    for i_row = 1 : num_rows
        for i_col = 1 : num_cols
            app.plot_handles.fitness_compare.p{i_row, i_col}.ColorLimits = [c_min, c_max];
        end
    end
end
