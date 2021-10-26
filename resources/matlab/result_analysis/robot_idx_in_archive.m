function idx = robot_idx_in_archive(app, x ,y)
    for idx = 1 : size(app.current_gen_archive, 1)
        if (app.current_gen_x_idx(idx) == x)
            if (app.current_gen_y_idx(idx) == y)
                return;
            end
        end
    end
    idx = -1;
end
