function plot_parentage_related(app)
    if isempty(app.current_result) || isempty(app.current_result.stat)
        return
    end
    result = app.current_result;
    if ~result.stat.has_parentage
        if ~result.plot_to_file
            msgbox(sprintf("%s has no parentage information", result.name));
        end
        return
    end

    num_rows = 2;
    num_cols = 4;
    fig = figure('units', 'normalized', 'outerposition', [0, 0, 1, 1]);
    if result.plot_to_file
        fig.Visible = 'off';
    end
    parentage = result.stat.robot_parentage(:);
    longevity = result.stat.robot_longevity(:);
    generation_raw = repmat(0 : result.evo_params.nb_gen + 1, result.evo_params.gen_size, 1);
    generation = generation_raw(:);
    fitness = result.stat.robot_fitness(:);
    valid_selection = (longevity ~= -1);
    valid_parentage = parentage(valid_selection);
    valid_longevity = longevity(valid_selection);
    valid_generation = generation(valid_selection);
    valid_fitness = fitness(valid_selection);

    elite_selection = result.stat.elite_robot_selection;
    elite_parentage = result.stat.robot_parentage(elite_selection);
    elite_longevity = result.stat.robot_longevity(elite_selection);
    elite_generation = generation_raw(elite_selection);
    elite_fitness = result.stat.robot_fitness(elite_selection);
    elite_parentage = elite_parentage(:);
    elite_longevity = elite_longevity(:);
    elite_generation = elite_generation(:);
    elite_fitness = elite_fitness(:);

    % get first gen data
    first_gens = result.archive{1}(:, 1) + 1;
    first_ids = result.archive{1}(:, 2) + 1;
    first_selection = sub2ind(size(result.stat.robot_parentage), first_ids, first_gens);
    first_parentage = parentage(first_selection);
    first_longevity = longevity(first_selection);
    first_generation = generation(first_selection);
    first_fitness = fitness(first_selection);
    first_elite_selection = false(size(elite_selection));
    first_elite_selection(first_selection) = true;
    first_elite_selection = first_elite_selection & elite_selection;
    first_elite_parentage = parentage(first_elite_selection);
    first_elite_longevity = longevity(first_elite_selection);
    first_elite_generation = generation(first_elite_selection);
    first_elite_fitness = fitness(first_elite_selection);

    % get mid gen data
    mid_gen_number = ceil(result.evo_params.nb_gen / 2);
    mid_gens = result.archive{mid_gen_number}(:, 1) + 1;
    mid_ids = result.archive{mid_gen_number}(:, 2) + 1;
    mid_selection = sub2ind(size(result.stat.robot_parentage), mid_ids, mid_gens);
    mid_parentage = parentage(mid_selection);
    mid_longevity = longevity(mid_selection);
    mid_generation = generation(mid_selection);
    mid_fitness = fitness(mid_selection);
    mid_elite_selection = false(size(elite_selection));
    mid_elite_selection(mid_selection) = true;
    mid_elite_selection = mid_elite_selection & elite_selection;
    mid_elite_parentage = parentage(mid_elite_selection);
    mid_elite_longevity = longevity(mid_elite_selection);
    mid_elite_generation = generation(mid_elite_selection);
    mid_elite_fitness = fitness(mid_elite_selection);

    % get final gen data
    final_gens = result.archive{result.evo_params.nb_gen}(:, 1) + 1;
    final_ids = result.archive{result.evo_params.nb_gen}(:, 2) + 1;
    final_selection = sub2ind(size(result.stat.robot_parentage), final_ids, final_gens);
    final_parentage = parentage(final_selection);
    final_longevity = longevity(final_selection);
    final_generation = generation(final_selection);
    final_fitness = fitness(final_selection);
    final_elite_selection = false(size(elite_selection));
    final_elite_selection(final_selection) = true;
    final_elite_selection = final_elite_selection & elite_selection;
    final_elite_parentage = parentage(final_elite_selection);
    final_elite_longevity = longevity(final_elite_selection);
    final_elite_generation = generation(final_elite_selection);
    final_elite_fitness = fitness(final_elite_selection);

    % Legends
    all_robots_legend = sprintf("all robots (%d)", length(fitness));
    archived_robots_legend = sprintf("archived robots (%d)", sum(valid_selection));
    init_archive_legend = sprintf("init archive (%d)", length(first_gens));
    mid_archive_legend = sprintf("mid archive (%d)", length(mid_gens));
    final_archive_legend = sprintf("final archive (%d)", length(final_gens));
    archived_elites_legend = sprintf("archive elites (%d)", sum(sum(elite_selection)));
    init_archive_elite_legend = sprintf("init archive elites (%d)", sum(sum(first_elite_selection)));
    mid_archive_elite_legend = sprintf("mid archive elites (%d)", sum(sum(mid_elite_selection)));
    final_archive_elite_legend = sprintf("final archive elites (%d)", sum(sum(final_elite_selection)));

    grid_x = 1; grid_y = 1;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x); % TODO: dirty hack here as subplot's ordering is row first
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    scatter(ph, longevity, parentage, 'filled', 'DisplayName', all_robots_legend);
    scatter(ph, first_longevity, first_parentage, 'filled', 'DisplayName', init_archive_legend);
    scatter(ph, mid_longevity, mid_parentage, 'filled', 'DisplayName', mid_archive_legend);
    scatter(ph, final_longevity, final_parentage, 'filled', 'DisplayName', final_archive_legend);
    xlim(ph, [-0.5, result.evo_params.nb_gen + 0.5]);
    xlabel(ph, 'Longevity');
    ylabel(ph, 'Parentage');
    title(ph, "Parentage vs Longevity", 'Interpreter', 'none');
    legend(ph, 'Interpreter', 'none', 'Location', 'best');

    grid_x = 1; grid_y = 2;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x);
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    scatter(ph, valid_longevity, valid_parentage, 'filled', 'DisplayName', archived_robots_legend);
    scatter(ph, first_longevity, first_parentage, 'filled', 'DisplayName', init_archive_legend);
    scatter(ph, mid_longevity, mid_parentage, 'filled', 'DisplayName', mid_archive_legend);
    scatter(ph, final_longevity, final_parentage, 'filled', 'DisplayName', final_archive_legend);
    xlim(ph, [-0.5, result.evo_params.nb_gen + 0.5]);
    xlabel(ph, 'Longevity');
    ylabel(ph, 'Parentage');
    title(ph, "Parentage vs Longevity (Archived)", 'Interpreter', 'none');
    legend(ph, 'Interpreter', 'none', 'Location', 'best');

    grid_x = 1; grid_y = 3;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x); % TODO: dirty hack here as subplot's ordering is row first
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    scatter(ph, elite_longevity, elite_parentage, 'filled', 'DisplayName', archived_elites_legend);
    scatter(ph, first_elite_longevity, first_elite_parentage, 'filled', 'DisplayName', init_archive_elite_legend);
    scatter(ph, mid_elite_longevity, mid_elite_parentage, 'filled', 'DisplayName', mid_archive_elite_legend);
    scatter(ph, final_elite_longevity, final_elite_parentage, 'filled', 'DisplayName', final_archive_elite_legend);
    xlim(ph, [-0.5, result.evo_params.nb_gen + 0.5]);
    xlabel(ph, 'Longevity');
    ylabel(ph, 'Parentage');
    title(ph, "Parentage vs Longevity (Elites)", 'Interpreter', 'none');
    legend(ph, 'Interpreter', 'none', 'Location', 'best');

    grid_x = 1; grid_y = 4;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x);
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    scatter(ph, valid_generation, valid_parentage, 'filled', 'DisplayName', archived_robots_legend);
    scatter(ph, first_generation, first_parentage, 'filled', 'DisplayName', init_archive_legend);
    scatter(ph, mid_generation, mid_parentage, 'filled', 'DisplayName', mid_archive_legend);
    scatter(ph, final_generation, final_parentage, 'filled', 'DisplayName', final_archive_legend);
    xlabel(ph, 'Generation');
    ylabel(ph, 'Parentage');
    title(ph, "Parentage vs Generation", 'Interpreter', 'none');
    legend(ph, 'Interpreter', 'none', 'Location', 'best');

    grid_x = 2; grid_y = 1;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x);
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    scatter(ph, fitness, parentage, 'filled', 'DisplayName', all_robots_legend);
    scatter(ph, first_fitness, first_parentage, 'filled', 'DisplayName', init_archive_legend);
    scatter(ph, mid_fitness, mid_parentage, 'filled', 'DisplayName', mid_archive_legend);
    scatter(ph, final_fitness, final_parentage, 'filled', 'DisplayName', final_archive_legend);
    xlabel(ph, 'Fitness');
    ylabel(ph, 'Parentage');
    title(ph, "Parentage vs Fitness", 'Interpreter', 'none');
    % legend(ph, 'Interpreter', 'none', 'Location', 'best');

    grid_x = 2; grid_y = 2;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x);
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    scatter(ph, valid_fitness, valid_parentage, 'filled', 'DisplayName', archived_robots_legend);
    scatter(ph, first_fitness, first_parentage, 'filled', 'DisplayName', init_archive_legend);
    scatter(ph, mid_fitness, mid_parentage, 'filled', 'DisplayName', mid_archive_legend);
    scatter(ph, final_fitness, final_parentage, 'filled', 'DisplayName', final_archive_legend);
    xlabel(ph, 'Fitness');
    ylabel(ph, 'Parentage');
    title(ph, "Parentage vs Fitness (Archived)", 'Interpreter', 'none');
    % legend(ph, 'Interpreter', 'none', 'Location', 'best');

    grid_x = 2; grid_y = 3;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x);
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    scatter(ph, elite_fitness, elite_parentage, 'filled', 'DisplayName', archived_elites_legend);
    scatter(ph, first_elite_fitness, first_elite_parentage, 'filled', 'DisplayName', init_archive_elite_legend);
    scatter(ph, mid_elite_fitness, mid_elite_parentage, 'filled', 'DisplayName', mid_archive_elite_legend);
    scatter(ph, final_elite_fitness, final_elite_parentage, 'filled', 'DisplayName', final_archive_elite_legend);
    xlabel(ph, 'Fitness');
    ylabel(ph, 'Parentage');
    title(ph, "Parentage vs Fitness (Elites)", 'Interpreter', 'none');
    % legend(ph, 'Interpreter', 'none', 'Location', 'best');

    grid_x = 2; grid_y = 4;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x);
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    scatter(ph, valid_generation, valid_fitness, 'filled', 'DisplayName', archived_robots_legend);
    scatter(ph, first_generation, first_fitness, 'filled', 'DisplayName', init_archive_legend);
    scatter(ph, mid_generation, mid_fitness, 'filled', 'DisplayName', mid_archive_legend);
    scatter(ph, final_generation, final_fitness, 'filled', 'DisplayName', final_archive_legend);
    xlabel(ph, 'Generation');
    ylabel(ph, 'Fitness');
    title(ph, "Fitness vs Generation", 'Interpreter', 'none');
    % legend(ph, 'Interpreter', 'none', 'Location', 'best');

    sgtitle(sprintf("%s - Parentage & Longevity Distribution", result.name), 'Interpreter', 'none');

    if result.plot_to_file
        for i_format = 1 : length(result.plot_format)
            saveas(fig, fullfile(result.plot_dir, ['parentage_related_', result.name, '.', result.plot_format{i_format}]));
        end
        close(fig);
    end
end
