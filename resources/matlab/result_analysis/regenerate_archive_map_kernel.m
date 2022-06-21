function regenerate_archive_map_kernel(app, result_id)
    griddim_0 = 20;
    griddim_1 = 20;

    load_result_robots(app, result_id);
    result = load_target_result(app, false, result_id);

    % archive map: [gen_id, id, f_id1, f_id2, fitness]
    % robot: 3d matrix (nb_robots_per_gen, 9, nb_gen + 1)
    % [p1_gid, p1_id, p2_gid, p2_id, f_id1, f_id2, f1, f2, fitness]
    map = -inf(400, 5);
    archive = {};
    nb_gen = result.evo_params.nb_gen;
    wb_gen = waitbar(double(0), '', 'Name', result.name);
    for i_gen = 0 : nb_gen
        waitbar(double(i_gen + 1) / double(nb_gen + 1), wb_gen, ...
                sprintf("Processing %d / %d", i_gen + 1, nb_gen + 1));
        robots = result.robots(:, :, i_gen + 1);
        for i_robot = 0 : size(robots, 1) - 1
            robot = robots(i_robot + 1, :);
            x = round(robot(7) * (griddim_0 - 1));
            y = round(robot(8) * (griddim_1 - 1));
            map_idx = sub2ind([20, 20], y + 1, x + 1); % after manually testing, this is the serializing order used in trainer
            if map(map_idx, 5) < robot(9)
                map(map_idx, 1) = i_gen;
                map(map_idx, 2) = i_robot;
                map(map_idx, 3) = x;
                map(map_idx, 4) = y;
                map(map_idx, 5) = robot(9);
            end
        end
        archive{i_gen + 1} = map(~isinf(map(:, 5)), :);
   end
   app.results{result.id}.archive = archive;
   save(fullfile(result.path, 'archive.mat'), 'archive', '-v7.3');

   if ~isempty(app.current_result) && app.current_result.id == result.id
       app.current_result.archive = archive;
   end
   close(wb_gen);
end
