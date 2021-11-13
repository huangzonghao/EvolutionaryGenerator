function plot_parentage_distribution(app)
    if ~app.stat.has_parentage
        return
    end
    figure();
    parentage_map = zeros(app.evo_params.griddim_0, app.evo_params.griddim_1);
    % gridmap format : gen_id, id, f_id1, f_id2, fitness
    x = app.current_gen_archive(:, 3) + 1; % remember matlab index starts from 1
    y = app.current_gen_archive(:, 4) + 1;
    parentage_dist = app.stat.robot_parentage(sub2ind(size(app.stat.robot_parentage), app.current_gen_archive(:,2) + 1, app.current_gen_archive(:,1) + 1));
    parentage_map(sub2ind(size(parentage_map), x, y)) = parentage_dist;
    heatmap(parentage_map, 'ColorLimits', [0, 1]);
end
