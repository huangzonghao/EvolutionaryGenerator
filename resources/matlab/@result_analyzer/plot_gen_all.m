function plot_gen_all(app)
% Plot all plots related to a specific generation

    % Configure panels here
    if ~isfield(app.plot_handles.gen_plot, 'handle') || ~ishandle(app.plot_handles.gen_plot.handle)
        return
    elseif ~app.current_result.plot_to_file
        figure(app.plot_handles.gen_plot.handle);
    end

    f1_selection = app.Feature1DropDown.Value;
    f2_selection = app.Feature2DropDown.Value;
    if f1_selection == f2_selection
        msgbox('Select different feature pairs to plot');
        return
    end

    % if we can create a handle then it's guaranteed that we have a current_result
    result = app.current_result;
    current_gen = app.current_gen;
    grid_dim = result.evo_params.grid_dim;
    map_size = app.plot_handles.gen_plot.map_size;
    % check if the size of the selected grid dimensions match the ones of the map
    if map_size(1) ~= grid_dim(f1_selection) || ...
       map_size(2) ~= grid_dim(f2_selection)
       msgbox("Number of bins of selected features don't match the size of the map");
       return
    end
    f1_string = result.evo_params.feature_description(f1_selection);
    f2_string = result.evo_params.feature_description(f2_selection);

    archive_map = nan(map_size);
    app.archive_ids = zeros(map_size);
    current_gen_archive = result.archive{current_gen + 1};
    % f_ids: a N x 2 matrix holding the feature ids of the robots in the archive
    %     map. N is the number of robots. 1st column is the 1st feature, 2nd column
    %     is the second feature.
    if result.version < 2
        f_ids(:, 1) = current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
        f_ids(:, 2) = current_gen_archive(:, 4) + 1;
        fitness = current_gen_archive(:, 5);
    else
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
    if app.SanitizeArchiveCheckBox.Value == true && length(fitness) == length(archive_map(:))
        % sanitize the second dimension (here map_size(1) gives the size of first dimension)
        fitness(sub2ind(size(archive_map), 1:map_size(1), ones(1, map_size(1)))) = 0.1 * rand(map_size(1), 1) + fitness(sub2ind(size(archive_map), 1:map_size(1), 1 + ones(1, map_size(1))));
    end
    archive_map(sub2ind(size(archive_map), f_ids(:, 1), f_ids(:, 2))) = fitness;
    if result.version < 2
        app.archive_ids(sub2ind(size(archive_map), f_ids(:, 1), f_ids(:, 2))) = [1:length(fitness)];
    else
        app.archive_ids(sub2ind(size(archive_map), f_ids(:, 1), f_ids(:, 2))) = f_ids(:, 4);
    end
    app.current_result.current_archive_map = archive_map;

    if result.version < 2
        parentage_map = nan(map_size);
        if isfield(result.stat, 'has_parentage') && result.stat.has_parentage
            parentage_dist = result.stat.robot_parentage(sub2ind(size(result.stat.robot_parentage), current_gen_archive(:,2) + 1, current_gen_archive(:,1) + 1));
            parentage_map(sub2ind(size(parentage_map), f_ids(:, 1), f_ids(:, 2))) = parentage_dist;
        end

        ages = current_gen_archive(:, 1);
        age_map = nan(map_size);
        age_map(sub2ind(size(age_map), f_ids(:, 1), f_ids(:, 2))) = double(current_gen) * ones(size(ages)) - ages;
        updates_per_bin = result.stat.map_stat(:, :, current_gen + 1);
        updates_per_bin(updates_per_bin == 0) = NaN;
    end

    % Generate the plots
    surf_archive_map = zeros(size(archive_map));
    tmp_idx = ~isnan(archive_map);
    surf_archive_map(tmp_idx) = archive_map(tmp_idx);
    app.plot_handles.gen_plot.archive_surf.ZData = surf_archive_map;
    app.plot_handles.gen_plot.archive_surf.ZData = surf_archive_map;
    app.plot_handles.gen_plot.archive_heat.ColorData = archive_map;
    if result.version < 2
        app.plot_handles.gen_plot.updates_per_bin_heat.ColorData = updates_per_bin;
        app.plot_handles.gen_plot.parentage_heat.ColorData = parentage_map;
        app.plot_handles.gen_plot.bin_age_heat.ColorData = age_map;
        app.plot_handles.gen_plot.archive_hist.Data = fitness;
    else
        app.plot_handles.gen_plot.archive_hist.Data = fitness_all;
    end
    drawnow;
    if result.version < 2
        app.plot_handles.gen_plot.info_text.String = ...
            sprintf("%s - Gen %d / %d, Coverage %d / %d", ...
            result.name, current_gen, result.evo_params.nb_gen, ...
            length(fitness), prod(map_size));
    else
        app.plot_handles.gen_plot.info_text.String = ...
            sprintf("%s - Gen %d / %d, 2D Coverage %d / %d, Coverage %d / %d", ...
            result.name, current_gen, result.evo_params.nb_gen, ...
            length(fitness), prod(map_size), ...
            length(fitness_all), prod(grid_dim));
    end
    % Reset the title text proterties
    % TODO: for some reason we have to update this title font set up here, and
    % settings in open_gen_all_plot.m won't work.
    app.plot_handles.gen_plot.archive_surf_title.FontSize = 11;
    app.plot_handles.gen_plot.archive_surf_title.FontWeight = 'bold';
    app.plot_handles.gen_plot.archive_hist_title.FontSize = 11;
    app.plot_handles.gen_plot.archive_hist_title.FontWeight = 'bold';

    % Update the feature labels
    xlabel(app.plot_handles.gen_plot.archive_surf_ax, f2_string);
    ylabel(app.plot_handles.gen_plot.archive_surf_ax, f1_string);
    app.plot_handles.gen_plot.archive_heat.XLabel = f2_string;
    app.plot_handles.gen_plot.archive_heat.YLabel = f1_string;
    if result.version < 2
        app.plot_handles.gen_plot.parentage_heat.XLabel = f2_string;
        app.plot_handles.gen_plot.parentage_heat.YLabel = f1_string;
        app.plot_handles.gen_plot.updates_per_bin_heat.XLabel = f2_string;
        app.plot_handles.gen_plot.updates_per_bin_heat.YLabel = f1_string;
        app.plot_handles.gen_plot.bin_age_heat.XLabel = f2_string;
        app.plot_handles.gen_plot.bin_age_heat.YLabel = f1_string;
    end

    if result.plot_to_file
        for i_format = 1 : length(result.plot_format)
            saveas(app.plot_handles.gen_plot.handle, fullfile(result.plot_dir, ['gen_all_', result.name, '_gen', num2str(app.current_gen), '.', result.plot_format{i_format}]));
        end
    else
        % Note the swapping of f_ids(1, 1), f_ids(1, 2) here
        app.RobotIDXField.Value = num2str(f_ids(1, 2));
        app.RobotIDYField.Value = num2str(f_ids(1, 1));
    end
end
