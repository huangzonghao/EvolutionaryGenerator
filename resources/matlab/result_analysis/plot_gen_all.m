function plot_gen_all(app)
% Plot all plots related to a specific generation

    % Configure panels here
    if ~isfield(app.gen_plot, 'handle') || ~ishandle(app.gen_plot.handle)
        return
    else
        figure(app.gen_plot.handle);
    end

    app.archive_map = zeros(app.evo_params.griddim_0, app.evo_params.griddim_1);
    app.archive_ids = zeros(app.evo_params.griddim_0, app.evo_params.griddim_1);
    x = app.current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
    y = app.current_gen_archive(:, 4) + 1;
    fitness = app.current_gen_archive(:, 5);
    app.archive_map(sub2ind(size(app.archive_map), x, y)) = fitness;
    app.archive_ids(sub2ind(size(app.archive_map), x, y)) = [1:length(fitness)];

    parentage_map = -1 * ones(app.evo_params.griddim_0, app.evo_params.griddim_1);
    if isfield(app.stat, 'has_parentage') && app.stat.has_parentage
        parentage_dist = app.stat.robot_parentage(sub2ind(size(app.stat.robot_parentage), app.current_gen_archive(:,2) + 1, app.current_gen_archive(:,1) + 1));
        parentage_map(sub2ind(size(parentage_map), x, y)) = parentage_dist;
    end

    ages = app.current_gen_archive(:, 1);
    age_map = double(-1) * ones(app.evo_params.griddim_0, app.evo_params.griddim_1);
    age_map(sub2ind(size(age_map), x, y)) = double(app.current_gen) * ones(size(ages)) - ages;

    % Generate the plots
    app.gen_plot.archive_surf.ZData = app.archive_map;
    app.gen_plot.archive_heat.ColorData = app.archive_map;
    app.gen_plot.updates_per_bin_heat.ColorData = app.stat.map_stat(:, :, app.current_gen + 1);
    app.gen_plot.parentage_heat.ColorData = parentage_map;
    app.gen_plot.bin_age_heat.ColorData = age_map;

    app.gen_plot.info_text.String = sprintf("%s\nGen %d / %d\nCoverage %d / %d", ...
                                            app.result_displayname, app.current_gen, app.evo_params.nb_gen, ...
                                            length(fitness), app.evo_params.griddim_0 * app.evo_params.griddim_1);
    drawnow;

    % Note the swapping of x, y here
    app.RobotIDXField.Value = num2str(y(1));
    app.RobotIDYField.Value = num2str(x(1));
end
