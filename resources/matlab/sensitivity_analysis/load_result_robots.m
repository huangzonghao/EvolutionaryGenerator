function load_result_robots(app, result_idx_to_load)
% extra results field after loaded:
%     robots: 3d matrix (nb_robots_per_gen, 9, nb_gen + 1)
%             robots format: [p1_gid, p1_id, p2_gid, p2_id, f_id1, f_id2, f1, f2, fitness]
%             Note the robot id starts from 0, so always +1 when retriving data from matlab array

    if length(app.results) == 0 || result_idx_to_load == -1
        return
    end

    for i = 1 : length(result_idx_to_load)
        result_idx = result_idx_to_load(i);

        % if the result has not been loaded yet, load it first
        if app.results{result_idx}.loaded == false
            load_result(app, result_idx_to_load);
        end

        if isfield(app.results{result_idx}, 'robots')
            continue
        end

        robots_container = load(fullfile(app.results{result_idx}.path, 'robots.mat'));
        app.results{result_idx}.robots = robots_container.robots;
    end
end
