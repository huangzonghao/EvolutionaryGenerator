function plot_parentage_trace(app)

    % This parentage trace plot requires robots information, so we don't mess
    % with the app.current_result, since app.current_result contains some other
    % fields than app.results
    current_result_id = app.current_result.id;
    if ~isfield(app.results{current_result_id}, 'robots')
        load_result_robots(app, current_result_id);
    end
    result = app.results{current_result_id};

    % Note the XY has been flipped already in gui layout
    fid_x = str2double(app.RobotIDXField.Value);
    fid_y = str2double(app.RobotIDYField.Value);
    if fid_x <= 0 || fid_x > result.evo_params.griddim_0 || fid_y <=0 || fid_y > result.evo_params.griddim_1
        msgbox(sprintf("Error: Invalid robot coord (%d, %d)", fid_y, fid_x));
    end

    % The following code gets the gen_id and id of a robot, given f_id1 and f_id2
    id_in_archive = app.archive_ids(fid_x, fid_y);
    if (id_in_archive == 0)
        msgbox("Error: Cell (" + app.RobotIDXField.Value + ", " + app.RobotIDYField.Value + ") of Gen " + num2str(app.current_gen) + " empty");
        return
    end
    current_gen_archive = result.archive{app.current_gen + 1};
    gen_id = current_gen_archive(id_in_archive, 1);
    id = current_gen_archive(id_in_archive, 2);

    ret_mat = [];

    while gen_id ~= -1
        curr_gen_robots = squeeze(result.robots(:, :, gen_id + 1));
        % curren_gen_robots: [p1_gid, p1_id, p2_gid, p2_id, f_id1, f_id2, f1, f2, fitness]
        robot_data = curr_gen_robots(id+1, :);
        % x, y, gen, id, fitness
        ret_mat = [ret_mat; robot_data(7), robot_data(8), gen_id, id, robot_data(9)];

        % now get the parent info
        gen_id = robot_data(1);
        id = robot_data(2);
    end
    h = figure('units','normalized','outerposition',[0.25 0 0.5 0.95]);
    sgtitle(sprintf("%s - Parentage Tree", result.name), 'Interpreter', 'none');
    p = panel(h);
    p.margintop = 20; % to allow space for sgtitle
    p.pack({3/4, 1/4});
    p(1).select()
    % subplot(2,1,1);
    scatter(ret_mat(:, 1), ret_mat(:,2), 10);
    xlim([-0.05, 1.05]);
    ylim([-0.05, 1.05]);
    text(ret_mat(:, 1) + 0.01, ret_mat(:,2) + 0.01, num2str(ret_mat(:,3)), 'Fontsize', 10)
    % for i = 1 : size(ret_mat, 1) - 1
        % annotation('arrow', ret_mat(i,1:2), ret_mat(i+1,1:2));
    % end
    axis square
    p(2).select();
    % subplot(2,1,2);
    plot(flip(ret_mat(:, 5)), '-o');
    text([1:size(ret_mat, 1)] - 0.05, flip(ret_mat(:,5)) + 0.3, string(flip(ret_mat(:, 3))));;
    xlabel('Generations');
    ylabel('Fitness');
    xlim([0.5, size(ret_mat, 1) + 0.5]);
    title(sprintf("total number of generations: %d", size(ret_mat, 1)))
end
