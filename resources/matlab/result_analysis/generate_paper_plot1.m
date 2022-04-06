function generate_paper_plot(app)
    if length(app.targets_to_compare) ~= 2
        msgbox('Select 2 results for paper plot');
        return
    end
    if app.targets_to_compare{1}.isgroup || app.targets_to_compare{2}.isgroup
        msgbox('Must be single result');
        return
    end

    feature_description2 = 'Leg Length SD';
    feature_description1 = 'Body Length';

    paper_fig = figure('Position', [100, 100, 800, 800]);
    paper_fig.PaperSize = [8.5, 8.5];
    fig_panel = panel(paper_fig);
    fig_panel.pack(2, 2);
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
    griddim = [result.evo_params.griddim_0, result.evo_params.griddim_1];
    % Gen 0
    current_gen = 0;
    current_gen_archive = result.archive{current_gen + 1};
    x = current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
    y = current_gen_archive(:, 4) + 1;
    fitness = current_gen_archive(:, 5);
    % % sanitize the second dimension (here griddim(1) gives the size of first dimension)
    % fitness(sub2ind(size(archive_map), 1:griddim(1), ones(1, griddim(1)))) = 0.1 * rand(griddim(1), 1) + fitness(sub2ind(size(archive_map), 1:griddim(1), 1 + ones(1, griddim(1))));
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

    % Gen 2000
    archive_map = nan([20, 20]);
    current_gen = 2000;
    current_gen_archive = result.archive{current_gen + 1};
    x = current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
    y = current_gen_archive(:, 4) + 1;
    fitness = current_gen_archive(:, 5);
    % sanitize the second dimension (here griddim(1) gives the size of first dimension)
    fitness(sub2ind(size(archive_map), 1:griddim(1), ones(1, griddim(1)))) = 0.1 * rand(griddim(1), 1) + fitness(sub2ind(size(archive_map), 1:griddim(1), 1 + ones(1, griddim(1))));
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

    % Result 2
    archive_map = nan([20, 20]);
    result = load_target_result(app, false, app.targets_to_compare{2}.id);
    griddim = [result.evo_params.griddim_0, result.evo_params.griddim_1];
    % Gen 0
    current_gen = 0;
    current_gen_archive = result.archive{current_gen + 1};
    x = current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
    y = current_gen_archive(:, 4) + 1;
    fitness = current_gen_archive(:, 5);
    % % sanitize the second dimension (here griddim(1) gives the size of first dimension)
    % fitness(sub2ind(size(archive_map), 1:griddim(1), ones(1, griddim(1)))) = 0.1 * rand(griddim(1), 1) + fitness(sub2ind(size(archive_map), 1:griddim(1), 1 + ones(1, griddim(1))));
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

    % Gen 2000
    archive_map = nan([20, 20]);
    current_gen = 2000;
    current_gen_archive = result.archive{current_gen + 1};
    x = current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
    y = current_gen_archive(:, 4) + 1;
    fitness = current_gen_archive(:, 5);
    % sanitize the second dimension (here griddim(1) gives the size of first dimension)
    fitness(sub2ind(size(archive_map), 1:griddim(1), ones(1, griddim(1)))) = 0.1 * rand(griddim(1), 1) + fitness(sub2ind(size(archive_map), 1:griddim(1), 1 + ones(1, griddim(1))));
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

    % Finally adjust the color limits of plots
    c_min = min([hm1.ColorLimits(1), hm2.ColorLimits(1), hm3.ColorLimits(1), hm4.ColorLimits(1)]);
    c_max = max([hm1.ColorLimits(2), hm2.ColorLimits(2), hm3.ColorLimits(2), hm4.ColorLimits(2)]);
    hm1.ColorLimits = [c_min, c_max];
    hm2.ColorLimits = [c_min, c_max];
    hm3.ColorLimits = [c_min, c_max];
    hm4.ColorLimits = [c_min, c_max];
    hm1.MissingDataColor = [1, 1, 1];
    hm3.MissingDataColor = [1, 1, 1];

    assignin('base', 'hm1', hm1);
    assignin('base', 'hm2', hm2);

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
        end
    end
    hm1.XLabel = '';
    hm3.XLabel = '';
    hm3.YLabel = '';
    hm4.YLabel = '';
    colormap(paper_fig, 'jet');

    % Save
    if ~isempty(app.CompPlotNameField.Value)
        exportgraphics(paper_fig, [app.CompPlotNameField.Value '.pdf']);
    end
end
