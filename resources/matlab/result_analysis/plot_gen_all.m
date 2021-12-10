function plot_gen_all(app)
% Plot all plots related to a specific generation

    % Configure panels here
    if ~isfield(app.gen_plot, 'handle') || ~ishandle(app.gen_plot.handle)
        return
    else
        figure(app.gen_plot.handle);
    end

    % if we can create a handle then it's guaranteed that we have a current_result
    result = app.current_result;
    current_gen = app.current_gen;

    archive_map = zeros(result.evo_params.griddim_0, result.evo_params.griddim_1);
    app.archive_ids = zeros(result.evo_params.griddim_0, result.evo_params.griddim_1);
    current_gen_archive = result.archive{current_gen + 1};
    x = current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
    y = current_gen_archive(:, 4) + 1;
    fitness = current_gen_archive(:, 5);
    archive_map(sub2ind(size(archive_map), x, y)) = fitness;
    app.archive_ids(sub2ind(size(archive_map), x, y)) = [1:length(fitness)];

    parentage_map = -1 * ones(result.evo_params.griddim_0, result.evo_params.griddim_1);
    if isfield(result.stat, 'has_parentage') && result.stat.has_parentage
        parentage_dist = result.stat.robot_parentage(sub2ind(size(result.stat.robot_parentage), current_gen_archive(:,2) + 1, current_gen_archive(:,1) + 1));
        parentage_map(sub2ind(size(parentage_map), x, y)) = parentage_dist;
    end

    ages = current_gen_archive(:, 1);
    age_map = double(-1) * ones(result.evo_params.griddim_0, result.evo_params.griddim_1);
    age_map(sub2ind(size(age_map), x, y)) = double(current_gen) * ones(size(ages)) - ages;

    % Generate the plots
    app.gen_plot.archive_surf.ZData = archive_map;
    app.gen_plot.archive_heat.ColorData = archive_map;
    app.gen_plot.updates_per_bin_heat.ColorData = result.stat.map_stat(:, :, current_gen + 1);
    app.gen_plot.parentage_heat.ColorData = parentage_map;
    app.gen_plot.bin_age_heat.ColorData = age_map;

    app.gen_plot.info_text.String = sprintf("%s\nGen %d / %d\nCoverage %d / %d", ...
                                            result.name, current_gen, result.evo_params.nb_gen, ...
                                            length(fitness), result.evo_params.griddim_0 * result.evo_params.griddim_1);
    drawnow;

    % Note the swapping of x, y here
    app.RobotIDXField.Value = num2str(y(1));
    app.RobotIDYField.Value = num2str(x(1));
end
