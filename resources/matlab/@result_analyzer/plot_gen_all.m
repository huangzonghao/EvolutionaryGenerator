function plot_gen_all(app)
% Plot all plots related to a specific generation

    % Configure panels here
    if ~isfield(app.plot_handles.gen_plot, 'handle') || ~ishandle(app.plot_handles.gen_plot.handle)
        return
    elseif ~app.current_result.plot_to_file
        figure(app.plot_handles.gen_plot.handle);
    end

    % if we can create a handle then it's guaranteed that we have a current_result
    result = app.current_result;
    current_gen = app.current_gen;
    griddim = [result.evo_params.griddim_0, result.evo_params.griddim_1];

    archive_map = nan(griddim);
    app.archive_ids = zeros(griddim);
    current_gen_archive = result.archive{current_gen + 1};
    x = current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
    y = current_gen_archive(:, 4) + 1;
    fitness = current_gen_archive(:, 5);
    if app.SanitizeArchiveCheckBox.Value == true && length(fitness) == length(archive_map(:))
        % sanitize the second dimension (here griddim(1) gives the size of first dimension)
        fitness(sub2ind(size(archive_map), 1:griddim(1), ones(1, griddim(1)))) = 0.1 * rand(griddim(1), 1) + fitness(sub2ind(size(archive_map), 1:griddim(1), 1 + ones(1, griddim(1))));
    end
    archive_map(sub2ind(size(archive_map), x, y)) = fitness;
    app.archive_ids(sub2ind(size(archive_map), x, y)) = [1:length(fitness)];
    app.current_result.current_archive_map = archive_map;

    parentage_map = nan(griddim);
    if isfield(result.stat, 'has_parentage') && result.stat.has_parentage
        parentage_dist = result.stat.robot_parentage(sub2ind(size(result.stat.robot_parentage), current_gen_archive(:,2) + 1, current_gen_archive(:,1) + 1));
        parentage_map(sub2ind(size(parentage_map), x, y)) = parentage_dist;
    end

    ages = current_gen_archive(:, 1);
    age_map = nan(griddim);
    age_map(sub2ind(size(age_map), x, y)) = double(current_gen) * ones(size(ages)) - ages;
    updates_per_bin = result.stat.map_stat(:, :, current_gen + 1);
    updates_per_bin(updates_per_bin == 0) = NaN;

    % Generate the plots
    surf_archive_map = zeros(size(archive_map));
    tmp_idx = ~isnan(archive_map);
    surf_archive_map(tmp_idx) = archive_map(tmp_idx);
    app.plot_handles.gen_plot.archive_surf.ZData = surf_archive_map;
    app.plot_handles.gen_plot.archive_heat.ColorData = archive_map;
    app.plot_handles.gen_plot.updates_per_bin_heat.ColorData = updates_per_bin;
    app.plot_handles.gen_plot.parentage_heat.ColorData = parentage_map;
    app.plot_handles.gen_plot.bin_age_heat.ColorData = age_map;
    app.plot_handles.gen_plot.archive_hist.Data = fitness;
    drawnow;
    app.plot_handles.gen_plot.info_text.String = sprintf("%s - Gen %d / %d, Coverage %d / %d", ...
                                            result.name, current_gen, result.evo_params.nb_gen, ...
                                            length(fitness), griddim(1) * griddim(2));
    % Reset the title text proterties
    % TODO: for some reason we have to update this title font set up here, and
    % settings in open_gen_all_plot.m won't work.
    app.plot_handles.gen_plot.archive_surf_title.FontSize = 11;
    app.plot_handles.gen_plot.archive_surf_title.FontWeight = 'bold';
    app.plot_handles.gen_plot.archive_hist_title.FontSize = 11;
    app.plot_handles.gen_plot.archive_hist_title.FontWeight = 'bold';

    if result.plot_to_file
        for i_format = 1 : length(result.plot_format)
            saveas(app.plot_handles.gen_plot.handle, fullfile(result.plot_dir, ['gen_all_', result.name, '_gen', num2str(app.current_gen), '.', result.plot_format{i_format}]));
        end
    else
        % Note the swapping of x, y here
        app.RobotIDXField.Value = num2str(y(1));
        app.RobotIDYField.Value = num2str(x(1));
    end
end
