function plot_gen_all(app)
% Plot all plots related to a specific generation

    % Configure panels here
    if ~isfield(app.gen_plot, 'handle') || ~ishandle(app.gen_plot.handle)
        app.gen_plot.handle = figure('outerposition',[180, 40, 1600, 1000]); % size for 1080p monitor
        app.gen_plot.panel = panel(app.gen_plot.handle);
        app.gen_plot.panel.marginright = 20; % so that we have some space for the heatmap colorbar
        app.gen_plot.panel.pack(2, 3);
        app.gen_plot.panel.de.margintop = 20;
        app.gen_plot.panel.de.marginbottom = 20;
        app.gen_plot.panel.de.marginleft = 20;
        app.gen_plot.panel.de.marginright = 30;

        % init all plots
        app.gen_plot.panel(1,1).select();
        app.gen_plot.archive_surf = surf(zeros(app.evo_params.griddim_0, app.evo_params.griddim_1));
        xlabel(app.evo_params.feature_description2); % x, y flipped in plot
        ylabel(app.evo_params.feature_description1);
        title('Archive Map');
        axis square;

        app.gen_plot.panel(1,2).select();
        app.gen_plot.archive_heat = heatmap(zeros(app.evo_params.griddim_0, app.evo_params.griddim_1));
        app.gen_plot.archive_heat.NodeChildren(3).YDir='normal';
        app.gen_plot.archive_heat.XLabel = app.evo_params.feature_description2;
        app.gen_plot.archive_heat.YLabel = app.evo_params.feature_description1;
        app.gen_plot.archive_heat.Title = 'Archive Map';

        app.gen_plot.panel(1,3).select();
        app.gen_plot.parentage_heat = heatmap(double(-1) * ones(app.evo_params.griddim_0, app.evo_params.griddim_1));
        app.gen_plot.parentage_heat.ColorLimits = [0, 1];
        app.gen_plot.parentage_heat.NodeChildren(3).YDir='normal';
        app.gen_plot.parentage_heat.XLabel = app.evo_params.feature_description2;
        app.gen_plot.parentage_heat.YLabel = app.evo_params.feature_description1;
        app.gen_plot.parentage_heat.Title = 'Percentage of User Input Per Robot';

        app.gen_plot.panel(2,2).select();
        app.gen_plot.updates_per_bin_heat = heatmap(double(-1) * ones(app.evo_params.griddim_0, app.evo_params.griddim_1));
        app.gen_plot.updates_per_bin_heat.NodeChildren(3).YDir='normal';
        app.gen_plot.updates_per_bin_heat.XLabel = app.evo_params.feature_description2;
        app.gen_plot.updates_per_bin_heat.YLabel = app.evo_params.feature_description1;
        app.gen_plot.updates_per_bin_heat.Title = 'Total Updates Per Bin';

        app.gen_plot.panel(2,3).select();
        app.gen_plot.bin_age_heat = heatmap(double(-1) * ones(app.evo_params.griddim_0, app.evo_params.griddim_1));
        app.gen_plot.bin_age_heat.NodeChildren(3).YDir='normal';
        app.gen_plot.bin_age_heat.XLabel = app.evo_params.feature_description2;
        app.gen_plot.bin_age_heat.YLabel = app.evo_params.feature_description1;
        app.gen_plot.bin_age_heat.Title = 'Age of Each Bin';
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
    drawnow;

    % app.GenInfoLabel.Text =...
        % sprintf('Gen: %d/%d, Archive size: %d/%d',...
        % app.current_gen, app.evo_params.nb_gen, size(x, 1),...
        % app.evo_params.griddim_0 * app.evo_params.griddim_1);

    % Note the swapping of x, y here
    app.RobotIDXField.Value = num2str(y(1));
    app.RobotIDYField.Value = num2str(x(1));
end