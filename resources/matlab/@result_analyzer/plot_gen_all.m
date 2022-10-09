function plot_gen_all(app)
% Plot all plots related to a specific generation

    % Configure panels here
    gen_plot = app.plot_handles.gen_plot;
    if ~isfield(gen_plot, 'handle') || ~ishandle(gen_plot.handle)
        open_gen_all_plot(app);
    elseif ~app.current_result.plot_to_file
        figure(gen_plot.handle);
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
    map_size = gen_plot.map_size;
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
    gen_plot.archive_surf.ZData = surf_archive_map;
    gen_plot.archive_heat.ColorData = archive_map;
    if result.version < 2
        gen_plot.updates_per_bin_heat.ColorData = updates_per_bin;
        gen_plot.parentage_heat.ColorData = parentage_map;
        gen_plot.bin_age_heat.ColorData = age_map;
        gen_plot.archive_hist.Data = fitness;
        gen_plot.info_text.String = ...
            sprintf("%s - Gen %d / %d, Coverage %d / %d", ...
            result.name, current_gen, result.evo_params.nb_gen, ...
            length(fitness), prod(map_size));
    else
        gen_plot.archive_hist.Data = fitness_all;
        gen_plot.info_text.String = ...
            sprintf("%s - Gen %d / %d, 2D Coverage %d / %d, Coverage %d / %d", ...
            result.name, current_gen, result.evo_params.nb_gen, ...
            length(fitness), prod(map_size), ...
            length(fitness_all), prod(grid_dim));
    end
    drawnow;

    % Reset the title text proterties
    % TODO: for some reason we have to update this title font set up here, and
    % settings in open_gen_all_plot.m won't work.
    gen_plot.archive_surf_title.FontSize = 11;
    gen_plot.archive_surf_title.FontWeight = 'bold';
    gen_plot.archive_hist_title.FontSize = 11;
    gen_plot.archive_hist_title.FontWeight = 'bold';

    % Update the feature labels
    xlabel(gen_plot.archive_surf_ax, f2_string);
    ylabel(gen_plot.archive_surf_ax, f1_string);
    gen_plot.archive_heat.XLabel = f2_string;
    gen_plot.archive_heat.YLabel = f1_string;
    app.Feature1Label.Text = f1_string;
    app.Feature2Label.Text = f2_string;
    if result.version < 2
        gen_plot.parentage_heat.XLabel = f2_string;
        gen_plot.parentage_heat.YLabel = f1_string;
        gen_plot.updates_per_bin_heat.XLabel = f2_string;
        gen_plot.updates_per_bin_heat.YLabel = f1_string;
        gen_plot.bin_age_heat.XLabel = f2_string;
        gen_plot.bin_age_heat.YLabel = f1_string;
    end

    if result.plot_to_file
        for i_format = 1 : length(result.plot_format)
            saveas(gen_plot.handle, fullfile(result.plot_dir, ['gen_all_', result.name, '_gen', num2str(app.current_gen), '.', result.plot_format{i_format}]));
        end
    else
        % Automatically poping up the best performing robot in the archive map
        app.RobotIDXField.Value = num2str(f_ids(1, 1));
        app.RobotIDYField.Value = num2str(f_ids(1, 2));
    end

    % Plot the detailed archive map
    if result.version >= 2
        if app.DetailedMapCheckBox.Value
            gen_plot.dam_handle = plot_detailed_archive_maps(gen_plot, result.evo_params, current_gen_archive);
            % parfeval(@plot_detailed_archive_maps, 0, gen_plot, result.evo_params, current_gen_archive);
        end
    end

    app.plot_handles.gen_plot = gen_plot;
end

function open_gen_all_plot(app)
    if isempty(app.current_result)
        return
    end
    result = app.current_result;

    gen_plot = {};
    gen_plot.handle = figure('outerposition',[180, 40, 1600, 1000]); % size for 1080p monitor
    gen_plot.handle.NumberTitle = 'off';
    gen_plot.handle.Name = 'Plots of Result';

    if result.plot_to_file
        gen_plot.handle.Visible = 'off';
    end

    gen_plot.panel = panel(gen_plot.handle);
    gen_plot.panel.marginright = 20; % so that we have some space for the heatmap colorbar
    gen_plot.panel.pack('v', {1/100, 99/100});
    gen_plot.panel(1).select();
    axis off
    gen_plot.info_text = text(0, 0.8, "Gen Info");
    gen_plot.info_text.FontSize = 16;
    gen_plot.info_text.FontWeight = 'bold';
    gen_plot.info_text.Interpreter = 'none';

    plot_panel = gen_plot.panel(2);
    plot_panel.pack(2, 3);
    plot_panel.de.margintop = 20;
    plot_panel.de.marginbottom = 20;
    plot_panel.de.marginleft = 20;
    plot_panel.de.marginright = 30;

    % TODO: Assuming the grid has the same size on all dimensions
    map_size = result.evo_params.grid_dim(1:2);
    gen_plot.map_size = map_size;

    % init all plots
    plot_panel(1,1).select();
    gen_plot.archive_surf = surf(zeros(map_size));
    gen_plot.archive_surf_ax = gca;
    % TODO: for some reason, setting the title font here doesn't work.
    gen_plot.archive_surf_title = title('Archive Map', 'FontWeight', 'bold', 'FontSize', 12);
    axis square;

    plot_panel(2,1).select();
    gen_plot.archive_hist = histogram(0);
    gen_plot.archive_hist_title = title('Fitness Histogram', 'FontWeight', 'bold', 'FontSize', 12);

    plot_panel(1,2).select();
    gen_plot.archive_heat = heatmap(zeros(map_size));
    gen_plot.archive_heat.NodeChildren(3).YDir='normal';
    gen_plot.archive_heat.Title = 'Archive Map';
    gen_plot.archive_heat.MissingDataLabel = 'Nan';
    gen_plot.archive_heat.MissingDataColor = [1, 1, 1];
    colormap(gen_plot.archive_heat, 'jet');

    plot_panel(1,3).select();
    gen_plot.parentage_heat = heatmap(double(-1) * ones(map_size));
    gen_plot.parentage_heat.ColorLimits = [0, 1];
    gen_plot.parentage_heat.NodeChildren(3).YDir='normal';
    gen_plot.parentage_heat.Title = 'Percentage of User Input Per Robot';
    gen_plot.parentage_heat.MissingDataLabel = 'Nan';
    gen_plot.parentage_heat.MissingDataColor = [1, 1, 1];
    colormap(gen_plot.parentage_heat, 'jet');

    plot_panel(2,2).select();
    gen_plot.updates_per_bin_heat = heatmap(double(-1) * ones(map_size));
    gen_plot.updates_per_bin_heat.NodeChildren(3).YDir='normal';
    gen_plot.updates_per_bin_heat.Title = 'Total Updates Per Bin';
    gen_plot.updates_per_bin_heat.MissingDataLabel = 'Nan';
    gen_plot.updates_per_bin_heat.MissingDataColor = [1, 1, 1];
    gen_plot.updates_per_bin_heat.CellLabelColor = 'none';
    colormap(gen_plot.updates_per_bin_heat, 'jet');

    plot_panel(2,3).select();
    gen_plot.bin_age_heat = heatmap(double(-1) * ones(map_size));
    gen_plot.bin_age_heat.NodeChildren(3).YDir='normal';
    gen_plot.bin_age_heat.Title = 'Age of Each Bin';
    gen_plot.bin_age_heat.MissingDataLabel = 'Nan';
    gen_plot.bin_age_heat.MissingDataColor = [1, 1, 1];
    colormap(gen_plot.bin_age_heat, 'jet');

    app.plot_handles.gen_plot = gen_plot;
end

% TODO: make this function run asynchronously.
function dam_handle = plot_detailed_archive_maps(gen_plot, evo_params, current_gen_archive)
    % TODO: currently the detailed archive map is highly customized for the 4D map.
    grid_dim = evo_params.grid_dim;
    map_size = gen_plot.map_size;
    if length(grid_dim) ~= 4
        disp('returned');
        return
    end

    if ~isfield(gen_plot, 'dam_handle') || ... % dam: detailed archive map
       ~ishandle(gen_plot.dam_handle.fig)

        % mbox = msgbox('Creating detailed archive map ...');
        wb = waitbar(0, 'Creating detailed archive map ...');
        % Need to figure out how to setup title and the right figure physical size
        % dam_handle = figure('outerposition',[180, 40, 1600, 1000]); % size for 1080p monitor
        dam_handle = {};

        dam_handle.fig = figure('outerposition',[180, 40, 1600, 1000]);
        dam_handle.fig.Name = 'Detailed Archive Map';
        dam_handle.fig.NumberTitle = 'off';
        dam_handle.group = uitabgroup; % tabgroup
        num_maps = double(grid_dim(3) * grid_dim(4));
        counter = double(0);
        for i_forth = 1 : grid_dim(4)
            new_tab.handle = uitab(dam_handle.group, ...
                                   'Title', strcat(evo_params.feature_description(4), ' - ', ...
                                   num2str(i_forth))); % build tab
            axes('Parent', new_tab.handle);
            for i_third = 1 : grid_dim(3)
                subplot(2, 4, i_third);
                new_tab.heat{i_third} = heatmap(zeros(map_size));
                new_tab.heat{i_third}.NodeChildren(3).YDir='normal';
                new_tab.heat{i_third}.Title = strcat(evo_params.feature_description(3), ' - ', num2str(i_third));
                new_tab.heat{i_third}.MissingDataLabel = 'Nan';
                new_tab.heat{i_third}.MissingDataColor = [1, 1, 1];
                new_tab.heat{i_third}.XLabel = evo_params.feature_description(2);
                new_tab.heat{i_third}.YLabel = evo_params.feature_description(1);
                colormap(new_tab.heat{i_third}, 'jet');

                counter = counter + 1;
            end

            waitbar(counter / num_maps, wb)
            dam_handle.tab{i_forth} = new_tab;
        end
        close(wb);
    else
        dam_handle = gen_plot.dam_handle;
    end

    % Now update the plots here
    % Archive format each row: [gen_id, id, fitness, f_id1, f_id2, ...]
    for i_forth = 1 : grid_dim(4)
        tab_fits = current_gen_archive(current_gen_archive(:, 4 + 3) == i_forth - 1, :);
        for i_third = 1 : grid_dim(3)
            tmp_archive = nan(map_size);
            tmp_fits = tab_fits(tab_fits(:, 3 + 3) == i_third - 1, :);
            % if app.SanitizeArchiveCheckBox.Value == true && length(fitness) == length(tmp_archive(:))
            % % sanitize the second dimension (here map_size(1) gives the size of first dimension)
            % fitness(sub2ind(size(tmp_archive), 1:map_size(1), ones(1, map_size(1)))) = 0.1 * rand(map_size(1), 1) + fitness(sub2ind(size(tmp_archive), 1:map_size(1), 1 + ones(1, map_size(1))));
            % end
            tmp_archive(sub2ind(size(tmp_archive), tmp_fits(:, 1 + 3) + 1, tmp_fits(:, 2 + 3) + 1)) = tmp_fits(:, 3);

            dam_handle.tab{i_forth}.heat{i_third}.ColorData = tmp_archive;
        end
    end
end
