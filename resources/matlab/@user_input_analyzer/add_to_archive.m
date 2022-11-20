function add_to_archive(app, features, fitness, map_stat_id)
    features = squeeze(features);
    fitness = squeeze(fitness);
    if size(features, 1) ~= length(fitness)
        disp("Error: size of features doesn't match the size of fitenss. No update occured");
        return;
    end

    for i = 1 : length(fitness)
        x = min(app.map_dim_0, floor(features(i, 1) * double(app.map_dim_0)) + 1);
        y = min(app.map_dim_1, floor(features(i, 2) * double(app.map_dim_1)) + 1);
        % TODO: slightly different from the logic in training -- training also considers
        % the distance to the center of the bin
        if (app.archive_map(x, y) <= fitness(i) || sum(app.map_stat(x, y, :)) == 0)
            app.archive_map(x, y) = fitness(i);
        end
        app.map_stat(x, y, map_stat_id) = app.map_stat(x, y, map_stat_id) + 1;
    end
end
