function plot_parentage_related(app)
    num_rows = 2;
    num_cols = 4;
    if ~isfield(app.stat, 'robot_parentage')
        msgbox('This result has no parentage information available');
        return
    end
    figure();
    parentage = app.stat.robot_parentage(:);
    longevity = app.stat.robot_longevity(:);
    generation_raw = repmat(0 : app.evo_params.nb_gen + 1, app.evo_params.gen_size, 1);
    generation = generation_raw(:);
    fitness = app.stat.robot_fitness(:);
    valid_selection = (longevity ~= -1);
    valid_parentage = parentage(valid_selection);
    valid_longevity = longevity(valid_selection);
    valid_generation = generation(valid_selection);
    valid_fitness = fitness(valid_selection);

    elite_selection = app.stat.elite_robot_selection;
    elite_parentage = app.stat.robot_parentage(elite_selection);
    elite_longevity = app.stat.robot_longevity(elite_selection);
    elite_generation = generation_raw(elite_selection);
    elite_fitness = app.stat.robot_fitness(elite_selection);
    elite_parentage = elite_parentage(:);
    elite_longevity = elite_longevity(:);
    elite_generation = elite_generation(:);
    elite_fitness = elite_fitness(:);

    % get first gen data
    load_gen(app, 0); % load the final generation
    first_gens = app.current_gen_archive(:, 1) + 1;
    first_ids = app.current_gen_archive(:, 2) + 1;
    first_selection = sub2ind(size(app.stat.robot_parentage), first_ids, first_gens);
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
    load_gen(app, ceil(app.evo_params.nb_gen / 2)); % load the final generation
    mid_gens = app.current_gen_archive(:, 1) + 1;
    mid_ids = app.current_gen_archive(:, 2) + 1;
    mid_selection = sub2ind(size(app.stat.robot_parentage), mid_ids, mid_gens);
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
    load_gen(app, app.evo_params.nb_gen); % load the final generation
    final_gens = app.current_gen_archive(:, 1) + 1;
    final_ids = app.current_gen_archive(:, 2) + 1;
    final_selection = sub2ind(size(app.stat.robot_parentage), final_ids, final_gens);
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

    grid_x = 1; grid_y = 1;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x); % TODO: dirty hack here as subplot's ordering is row first
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    scatter(ph, longevity, parentage, 'filled', 'DisplayName', 'all robots');
    scatter(ph, first_longevity, first_parentage, 'filled', 'DisplayName', 'init archive');
    scatter(ph, mid_longevity, mid_parentage, 'filled', 'DisplayName', 'mid archive');
    scatter(ph, final_longevity, final_parentage, 'filled', 'DisplayName', 'final archive');
    xlim(ph, [-0.5, app.evo_params.nb_gen + 0.5]);
    xlabel(ph, 'Longevity');
    ylabel(ph, 'Parentage');
    title(ph, "Parentage vs Longevity", 'Interpreter', 'none');
    legend(ph, 'Interpreter', 'none');

    grid_x = 2; grid_y = 1;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x);
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    scatter(ph, fitness, parentage, 'filled', 'DisplayName', 'all robots');
    scatter(ph, first_fitness, first_parentage, 'filled', 'DisplayName', 'init archive');
    scatter(ph, mid_fitness, mid_parentage, 'filled', 'DisplayName', 'mid archive');
    scatter(ph, final_fitness, final_parentage, 'filled', 'DisplayName', 'final archive');
    xlabel(ph, 'Fitness');
    ylabel(ph, 'Parentage');
    title(ph, "Parentage vs Fitness", 'Interpreter', 'none');
    legend(ph, 'Interpreter', 'none');

    grid_x = 1; grid_y = 2;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x);
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    scatter(ph, valid_longevity, valid_parentage, 'filled', 'DisplayName', 'archived robots');
    scatter(ph, first_longevity, first_parentage, 'filled', 'DisplayName', 'init archive');
    scatter(ph, mid_longevity, mid_parentage, 'filled', 'DisplayName', 'mid archive');
    scatter(ph, final_longevity, final_parentage, 'filled', 'DisplayName', 'final archive');
    xlim(ph, [-0.5, app.evo_params.nb_gen + 0.5]);
    xlabel(ph, 'Longevity');
    ylabel(ph, 'Parentage');
    title(ph, "Parentage vs Longevity (Archived)", 'Interpreter', 'none');
    legend(ph, 'Interpreter', 'none');

    grid_x = 2; grid_y = 2;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x);
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    scatter(ph, valid_fitness, valid_parentage, 'filled', 'DisplayName', 'all robots');
    scatter(ph, first_fitness, first_parentage, 'filled', 'DisplayName', 'init archive');
    scatter(ph, mid_fitness, mid_parentage, 'filled', 'DisplayName', 'mid archive');
    scatter(ph, final_fitness, final_parentage, 'filled', 'DisplayName', 'final archive');
    xlabel(ph, 'Fitness');
    ylabel(ph, 'Parentage');
    title(ph, "Parentage vs Fitness (Archived)", 'Interpreter', 'none');
    legend(ph, 'Interpreter', 'none');

    grid_x = 1; grid_y = 3;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x); % TODO: dirty hack here as subplot's ordering is row first
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    scatter(ph, elite_longevity, elite_parentage, 'filled', 'DisplayName', 'archive elites');
    scatter(ph, first_elite_longevity, first_elite_parentage, 'filled', 'DisplayName', 'init archive elites');
    scatter(ph, mid_elite_longevity, mid_elite_parentage, 'filled', 'DisplayName', 'mid archive elites');
    scatter(ph, final_elite_longevity, final_elite_parentage, 'filled', 'DisplayName', 'final archive elites');
    xlim(ph, [-0.5, app.evo_params.nb_gen + 0.5]);
    xlabel(ph, 'Longevity');
    ylabel(ph, 'Parentage');
    title(ph, "Parentage vs Longevity (Elites)", 'Interpreter', 'none');
    legend(ph, 'Interpreter', 'none');

    grid_x = 2; grid_y = 3;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x);
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    scatter(ph, elite_fitness, elite_parentage, 'filled', 'DisplayName', 'archive elites');
    scatter(ph, first_elite_fitness, first_elite_parentage, 'filled', 'DisplayName', 'init archive elites');
    scatter(ph, mid_elite_fitness, mid_elite_parentage, 'filled', 'DisplayName', 'mid archive elites');
    scatter(ph, final_elite_fitness, final_elite_parentage, 'filled', 'DisplayName', 'final archive elites');
    xlabel(ph, 'Fitness');
    ylabel(ph, 'Parentage');
    title(ph, "Parentage vs Fitness (Elites)", 'Interpreter', 'none');
    legend(ph, 'Interpreter', 'none');

    grid_x = 1; grid_y = 4;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x);
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    scatter(ph, valid_generation, valid_parentage, 'filled', 'DisplayName', 'all robots');
    scatter(ph, first_generation, first_parentage, 'filled', 'DisplayName', 'init pop');
    scatter(ph, mid_generation, mid_parentage, 'filled', 'DisplayName', 'mid pop');
    scatter(ph, final_generation, final_parentage, 'filled', 'DisplayName', 'final pop');
    xlabel(ph, 'Generation');
    ylabel(ph, 'Parentage');
    title(ph, "Parentage vs Generation", 'Interpreter', 'none');
    legend(ph, 'Interpreter', 'none');

    grid_x = 2; grid_y = 4;
    plot_idx = sub2ind([num_cols, num_rows], grid_y, grid_x);
    ph = subplot(num_rows, num_cols, plot_idx, 'NextPlot', 'add');
    scatter(ph, valid_generation, valid_fitness, 'filled', 'DisplayName', 'all robots');
    scatter(ph, first_generation, first_fitness, 'filled', 'DisplayName', 'init pop');
    scatter(ph, mid_generation, mid_fitness, 'filled', 'DisplayName', 'mid pop');
    scatter(ph, final_generation, final_fitness, 'filled', 'DisplayName', 'final pop');
    xlabel(ph, 'Generation');
    ylabel(ph, 'Fitness');
    title(ph, "Fitness vs Generation", 'Interpreter', 'none');
    legend(ph, 'Interpreter', 'none', 'Location', 'SouthWest');

    % get the final points
    % plot the points int three batches so that we can see how the values transforms
    % longevity of map

    sgtitle(sprintf("%s - (%d)", app.result_displayname, sum(valid_selection)), 'Interpreter', 'none');
end
