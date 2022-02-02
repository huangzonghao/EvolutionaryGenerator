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
    fig_panel = panel(paper_fig);
    fig_panel.pack(2, 2);
    fig_panel.marginright = 20; % so that we have some space for the heatmap colorbar
    fig_panel.de.marginright = 30;
    fig_panel.de.margintop = 20;

    archive_map = zeros([20, 20]);

    % Result 1
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
    hm1.Title = 'Gen 0';

    % Gen 2000
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
    hm2.Title = 'Gen 2000';

    % Result 2
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
    hm3.Title = 'Gen 0';

    % Gen 2000
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
    hm4.Title = 'Gen 2000';

    % Finally adjust the color limits of plots
    c_min = min([hm1.ColorLimits(1), hm2.ColorLimits(1), hm3.ColorLimits(1), hm4.ColorLimits(1)]);
    c_max = max([hm1.ColorLimits(2), hm2.ColorLimits(2), hm3.ColorLimits(2), hm4.ColorLimits(2)]);
    hm1.ColorLimits = [c_min, c_max];
    hm2.ColorLimits = [c_min, c_max];
    hm3.ColorLimits = [c_min, c_max];
    hm4.ColorLimits = [c_min, c_max];
end
