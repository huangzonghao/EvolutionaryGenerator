function plot_parentage_related(app)
    num_rows = 2;
    num_cols = 2;
    if ~isfield(app.stat, 'robot_parentage')
        msgbox('This result has no parentage information available');
        return
    end
    figure();
    parentage = app.stat.robot_parentage(:);
    longevity = app.stat.robot_longevity(:);
    generation = repmat(0 : app.evo_params.nb_gen + 1, app.evo_params.gen_size, 1);
    generation = generation(:);
    fitness = app.stat.robot_fitness(:);
    valid_selection = (longevity ~= -1);
    valid_parentage = parentage(valid_selection);
    valid_longevity = longevity(valid_selection);
    valid_generation = generation(valid_selection);
    valid_fitness = fitness(valid_selection);

    % get first gen data
    load_gen(app, 0); % load the final generation
    first_gens = app.current_gen_archive(:, 1) + 1;
    first_ids = app.current_gen_archive(:, 2) + 1;
    first_selection = sub2ind(size(app.stat.robot_parentage), first_ids, first_gens);
    first_parentage = parentage(first_selection);
    first_longevity = longevity(first_selection);
    first_generation = generation(first_selection);
    first_fitness = fitness(first_selection);

    % get final gen data
    load_gen(app, app.evo_params.nb_gen); % load the final generation
    final_gens = app.current_gen_archive(:, 1) + 1;
    final_ids = app.current_gen_archive(:, 2) + 1;
    final_selection = sub2ind(size(app.stat.robot_parentage), final_ids, final_gens);
    final_parentage = parentage(final_selection);
    final_longevity = longevity(final_selection);
    final_generation = generation(final_selection);
    final_fitness = fitness(final_selection);

    p1 = subplot(num_cols, num_rows, 1, 'NextPlot', 'add');
    scatter(p1, valid_longevity, valid_parentage, 'filled', 'DisplayName', 'all robots');
    scatter(p1, first_longevity, first_parentage, 'filled', 'DisplayName', 'init pop');
    scatter(p1, final_longevity, final_parentage, 'filled', 'DisplayName', 'final pop');
    xlim(p1, [-0.5, app.evo_params.nb_gen + 0.5]);
    xlabel(p1, 'Longevity');
    ylabel(p1, 'Parentage');
    title(p1, "Parentage vs Longevity", 'Interpreter', 'none');
    legend(p1, 'Interpreter', 'none');

    p2 = subplot(num_cols, num_rows, 2, 'NextPlot', 'add');
    scatter(p2, valid_generation, valid_parentage, 'filled', 'DisplayName', 'all robots');
    scatter(p2, first_generation, first_parentage, 'filled', 'DisplayName', 'init pop');
    scatter(p2, final_generation, final_parentage, 'filled', 'DisplayName', 'final pop');
    xlabel(p2, 'Generation');
    ylabel(p2, 'Parentage');
    title(p2, "Parentage vs Generation", 'Interpreter', 'none');
    legend(p2, 'Interpreter', 'none');

    p3 = subplot(num_cols, num_rows, 3, 'NextPlot', 'add');
    scatter(p3, valid_fitness, valid_parentage, 'filled', 'DisplayName', 'all robots');
    scatter(p3, first_fitness, first_parentage, 'filled', 'DisplayName', 'init pop');
    scatter(p3, final_fitness, final_parentage, 'filled', 'DisplayName', 'final pop');
    xlabel(p3, 'Fitness');
    ylabel(p3, 'Parentage');
    title(p3, "Parentage vs Fitness", 'Interpreter', 'none');
    legend(p3, 'Interpreter', 'none');

    % get the final points
    % plot the points int three batches so that we can see how the values transforms
    % longevity of map

    sgtitle(sprintf("%s - (%d)", app.result_displayname, sum(valid_selection)), 'Interpreter', 'none');
end
