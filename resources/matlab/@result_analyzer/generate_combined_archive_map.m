function fig = generate_combined_archive_map(app)
    fig = figure();
    fig.Position = [100, 100, 540, 540];

    feature_description2 = '\bf Leg Length SD';
    feature_description1 = '\bf Body Length';

    gen = 2000;
    % gen = app.VideoGenIDField.Value;
    if gen > 2000
        msgbox('Error: gen > 2000')
        return
    end

    % note if we init archive_map in this way, the first mat would be all zero
    % due to archive_maps(:,:,end+1) will start from the second matrix
    % we need to remove the first mat before doing max
    archive_maps = [];
    for i_target = 1 : length(app.targets_to_compare)
        result = load_target_result(app, app.targets_to_compare{i_target}.isgroup, app.targets_to_compare{i_target}.id);
        if result.isgroup
            % group result
            for i_virtual_result = 1 : result.num_results
                child_result = load_target_result(app, false, result.ids(i_virtual_result));
                archive_maps(:,:,end+1) = get_result_archive_map(child_result, gen);
            end
        else
            % single result
            archive_maps(:,:,end+1) = get_result_archive_map(result, gen);
        end
    end

    archive_maps(:,:,1) = [];
    combined_map = max(archive_maps, [], 3);
    hm = heatmap(fig, combined_map);
    hm.NodeChildren(3).YDir='normal';
    hm.XLabel = feature_description2;
    hm.YLabel = feature_description1;
    hm_s = struct(hm);
    hm_s.XAxis.TickLabelRotation = 0; % undocumented function
    x_tick = {};
    for i_tick = 1 : length(hm.XDisplayLabels)
        if mod(i_tick, 5) == 0
            x_tick{i_tick} = num2str(i_tick);
        else
            x_tick{i_tick} = '';
        end
    end
    x_tick{1} = '1';
    hm.XDisplayLabels = x_tick;
    y_tick = {};
    for i_tick = 1 : length(hm.YDisplayLabels)
        if mod(i_tick, 5) == 0
            y_tick{i_tick} = num2str(i_tick);
        else
            y_tick{i_tick} = '';
        end
    end
    y_tick{1} = '1';
    hm.YDisplayLabels = y_tick;
    hm.FontColor = [0, 0, 0];
    hm.FontSize = 15;
    hm.FontName = 'Times New Roman';
    hm.MissingDataLabel = 'Nan';
    colormap(fig, 'jet');
end

function archive_map = get_result_archive_map(result, gen)
    grid_dim = result.evo_params.grid_dim;
    archive_map = nan(grid_dim);
    current_gen_archive = result.archive{gen + 1};
    x = current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
    y = current_gen_archive(:, 4) + 1;
    fitness = current_gen_archive(:, 5);
    % sanitize the second dimension (here grid_dim(1) gives the size of first dimension)
    fitness(sub2ind(size(archive_map), 1:grid_dim(1), ones(1, grid_dim(1)))) = 0.1 * rand(grid_dim(1), 1) + fitness(sub2ind(size(archive_map), 1:grid_dim(1), 1 + ones(1, grid_dim(1))));
    archive_map(sub2ind(size(archive_map), x, y)) = fitness;
    app.archive_ids(sub2ind(size(archive_map), x, y)) = [1:length(fitness)];
end
