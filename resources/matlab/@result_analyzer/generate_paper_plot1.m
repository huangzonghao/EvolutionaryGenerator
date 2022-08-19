function generate_paper_plot1(app)
% The figure for archive comparison
    if length(app.targets_to_compare) ~= 2
        msgbox('Select 2 results for paper plot');
        return
    end
    if app.targets_to_compare{1}.isgroup || app.targets_to_compare{2}.isgroup
        msgbox('Must be single result');
        return
    end

    plot_num_updates = true;

    feature_description2 = 'Leg Length SD';
    feature_description1 = 'Body Length';

    paper_fig = figure('Position', [100, 100, 800, 800]);
    paper_fig.PaperSize = [8.5, 8.5];
    fig_panel = panel(paper_fig);
    if plot_num_updates
        fig_panel.pack(3, 2);
    else
        fig_panel.pack(2, 2);
    end
    fig_panel.margintop = 10;
    fig_panel.marginbottom = 20;
    fig_panel.marginleft = 20; % so that we have some space for the heatmap colorbar
    fig_panel.marginright = 20; % so that we have some space for the heatmap colorbar
    fig_panel.de.marginright = 25;
    fig_panel.de.marginleft = 30;
    fig_panel.de.margintop = 20;
    fig_panel.de.marginbottom = 20;

    % Result 1
    archive_map = nan([20, 20]);
    result = load_target_result(app, false, app.targets_to_compare{1}.id);
    grid_dim = result.evo_params.grid_dim;
    % Gen 0
    current_gen = 0;
    current_gen_archive = result.archive{current_gen + 1};
    x = current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
    y = current_gen_archive(:, 4) + 1;
    fitness = current_gen_archive(:, 5);
    % % sanitize the second dimension (here grid_dim(1) gives the size of first dimension)
    % fitness(sub2ind(size(archive_map), 1:grid_dim(1), ones(1, grid_dim(1)))) = 0.1 * rand(grid_dim(1), 1) + fitness(sub2ind(size(archive_map), 1:grid_dim(1), 1 + ones(1, grid_dim(1))));
    archive_map(sub2ind(size(archive_map), x, y)) = fitness;
    fig_panel(1,1).select();
    hm1 = heatmap(archive_map);
    hm1.NodeChildren(3).YDir='normal';
    hm1.XLabel = feature_description2;
    hm1.YLabel = feature_description1;
    hm1.Title = 'H0 - Initial Population';
    hm1.FontColor = [0, 0, 0];
    hm1.FontSize = 15;
    hm1.FontName = 'Times New Roman';
    hm1.MissingDataLabel = 'Nan';
    colormap(hm1, 'jet');

    % Gen 2000
    archive_map = nan([20, 20]);
    current_gen = 2000;
    current_gen_archive = result.archive{current_gen + 1};
    x = current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
    y = current_gen_archive(:, 4) + 1;
    fitness = current_gen_archive(:, 5);
    % sanitize the second dimension (here grid_dim(1) gives the size of first dimension)
    fitness(sub2ind(size(archive_map), 1:grid_dim(1), ones(1, grid_dim(1)))) = 0.1 * rand(grid_dim(1), 1) + fitness(sub2ind(size(archive_map), 1:grid_dim(1), 1 + ones(1, grid_dim(1))));
    archive_map(sub2ind(size(archive_map), x, y)) = fitness;
    fig_panel(2,1).select();
    hm2 = heatmap(archive_map);
    hm2.NodeChildren(3).YDir='normal';
    hm2.XLabel = feature_description2;
    hm2.YLabel = feature_description1;
    hm2.Title = 'H0 - Final Population';
    hm2.FontColor = [0, 0, 0];
    hm2.FontSize = 15;
    hm2.FontName = 'Times New Roman';
    hm2.MissingDataLabel = 'Nan';
    colormap(hm2, 'jet');

    % Num Updates
    if plot_num_updates
        fig_panel(3,1).select();
        updates_per_bin = result.stat.map_stat(:, :, current_gen + 1);
        updates_per_bin(updates_per_bin == 0) = NaN;
        hm5 = heatmap(updates_per_bin);
        hm5.NodeChildren(3).YDir='normal';
        hm5.XLabel = feature_description2;
        hm5.YLabel = feature_description1;
        hm5.Title = 'H0 - Updates Per Bin';
        hm5.FontColor = [0, 0, 0];
        hm5.FontSize = 15;
        hm5.FontName = 'Times New Roman';
        hm5.MissingDataLabel = 'Nan';
    end

    % Result 2
    archive_map = nan([20, 20]);
    result = load_target_result(app, false, app.targets_to_compare{2}.id);
    grid_dim = result.evo_params.grid_dim;
    % Gen 0
    current_gen = 0;
    current_gen_archive = result.archive{current_gen + 1};
    x = current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
    y = current_gen_archive(:, 4) + 1;
    fitness = current_gen_archive(:, 5);
    % % sanitize the second dimension (here grid_dim(1) gives the size of first dimension)
    % fitness(sub2ind(size(archive_map), 1:grid_dim(1), ones(1, grid_dim(1)))) = 0.1 * rand(grid_dim(1), 1) + fitness(sub2ind(size(archive_map), 1:grid_dim(1), 1 + ones(1, grid_dim(1))));
    archive_map(sub2ind(size(archive_map), x, y)) = fitness;
    fig_panel(1,2).select();
    hm3 = heatmap(archive_map);
    hm3.NodeChildren(3).YDir='normal';
    hm3.XLabel = feature_description2;
    hm3.YLabel = feature_description1;
    hm3.Title = 'H25 - Initial Population';
    hm3.FontColor = [0, 0, 0];
    hm3.FontSize = 15;
    hm3.FontName = 'Times New Roman';
    hm3.MissingDataLabel = 'Nan';
    colormap(hm3, 'jet');

    % Gen 2000
    archive_map = nan([20, 20]);
    current_gen = 2000;
    current_gen_archive = result.archive{current_gen + 1};
    x = current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
    y = current_gen_archive(:, 4) + 1;
    fitness = current_gen_archive(:, 5);
    % sanitize the second dimension (here grid_dim(1) gives the size of first dimension)
    fitness(sub2ind(size(archive_map), 1:grid_dim(1), ones(1, grid_dim(1)))) = 0.1 * rand(grid_dim(1), 1) + fitness(sub2ind(size(archive_map), 1:grid_dim(1), 1 + ones(1, grid_dim(1))));
    archive_map(sub2ind(size(archive_map), x, y)) = fitness;
    fig_panel(2,2).select();
    hm4 = heatmap(archive_map);
    hm4.NodeChildren(3).YDir='normal';
    hm4.XLabel = feature_description2;
    hm4.YLabel = feature_description1;
    hm4.Title = 'H25 - Final Population';
    hm4.FontColor = [0, 0, 0];
    hm4.FontSize = 15;
    hm4.FontName = 'Times New Roman';
    hm4.MissingDataLabel = 'Nan';
    colormap(hm4, 'jet');

    % Num Updates
    if plot_num_updates
        fig_panel(3,2).select();
        updates_per_bin = result.stat.map_stat(:, :, current_gen + 1);
        updates_per_bin(updates_per_bin == 0) = NaN;
        hm6 = heatmap(updates_per_bin);
        hm6.NodeChildren(3).YDir='normal';
        hm6.XLabel = feature_description2;
        hm6.YLabel = feature_description1;
        hm6.Title = 'H25 - Updates Per Bin';
        hm6.FontColor = [0, 0, 0];
        hm6.FontSize = 15;
        hm6.FontName = 'Times New Roman';
        hm6.MissingDataLabel = 'Nan';
        % colormap(hm6, flipud(gray))
    end

    % Finally adjust the color limits of plots
    c_min = min([hm1.ColorLimits(1), hm2.ColorLimits(1), hm3.ColorLimits(1), hm4.ColorLimits(1)]);
    c_max = max([hm1.ColorLimits(2), hm2.ColorLimits(2), hm3.ColorLimits(2), hm4.ColorLimits(2)]);
    hm1.ColorLimits = [c_min, c_max];
    hm2.ColorLimits = [c_min, c_max];
    hm3.ColorLimits = [c_min, c_max];
    hm4.ColorLimits = [c_min, c_max];
    hm1.MissingDataColor = [1, 1, 1];
    hm3.MissingDataColor = [1, 1, 1];
    if plot_num_updates
        c_min = min([hm5.ColorLimits(1), hm6.ColorLimits(1)]);
        c_max = max([hm5.ColorLimits(2), hm6.ColorLimits(2)]);
        hm5.ColorLimits = [c_min, c_max];
        hm6.ColorLimits = [c_min, c_max];
        hm5.MissingDataColor = [1, 1, 1];
        hm6.MissingDataColor = [1, 1, 1];
    end

    % Remove the excess axis labels
    for i = 2 : 20
        if mod(i, 5) ~= 0
            hm1.XDisplayLabels{i} = nan;
            hm1.YDisplayLabels{i} = nan;
            hm2.XDisplayLabels{i} = nan;
            hm2.YDisplayLabels{i} = nan;
            hm3.XDisplayLabels{i} = nan;
            hm3.YDisplayLabels{i} = nan;
            hm4.XDisplayLabels{i} = nan;
            hm4.YDisplayLabels{i} = nan;
            if plot_num_updates
                hm5.XDisplayLabels{i} = nan;
                hm5.YDisplayLabels{i} = nan;
                hm6.XDisplayLabels{i} = nan;
                hm6.YDisplayLabels{i} = nan;
            end
        end
    end
    hm1.XLabel = '';
    hm3.XLabel = '';
    hm3.YLabel = '';
    hm4.YLabel = '';
    if plot_num_updates
        hm2.XLabel = '';
        hm4.XLabel = '';
        hm6.YLabel = '';
    end

    % Save
    if ~isempty(app.CompPlotNameField.Value)
        exportgraphics(paper_fig, [app.CompPlotNameField.Value '.pdf']);
    end
end
