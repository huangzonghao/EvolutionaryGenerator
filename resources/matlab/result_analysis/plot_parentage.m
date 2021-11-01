function plot_parentage(app)
    id_in_archive = app.archive_ids(str2double(app.RobotIDYField.Value), str2double(app.RobotIDXField.Value));
    if (id_in_archive == 0)
        app.RobotInfoLabel.Text = "Error: Cell (" + app.RobotIDXField.Value + ", " + app.RobotIDYField.Value + ") of Gen " + num2str(app.current_gen) + " empty";
        return
    end

    ret_mat = [];

    gen_id = app.current_gen_archive(id_in_archive, 1);
    id = app.current_gen_archive(id_in_archive, 2);

    while gen_id ~= -1
        load_new_robots_gen(app, gen_id);
        robot_data = app.robots_buffer(app.robots_buffer(:, 2)==id, :);
        % x, y, gen, id, fitness
        ret_mat = [ret_mat; robot_data(9), robot_data(10), gen_id, id, robot_data(11)];

        % now get the parent info
        gen_id = robot_data(3);
        id = robot_data(4);
    end
    h = figure('units','normalized','outerposition',[0.25 0 0.5 0.95]);
    p = panel(h);
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

function load_new_robots_gen(app, gen_id)
    if app.robots_gen ~= gen_id
        app.robots_buffer = readmatrix(fullfile(app.result_path, strcat('/robots/', num2str(gen_id), '.csv')));
        app.robots_gen = gen_id;
    end
end
