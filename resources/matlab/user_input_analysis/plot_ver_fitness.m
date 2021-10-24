function plot_ver_fitness(app)
    if length(app.ListBox.Value) > 1
        msgbox("Select one user only to generate the fitness plot", "Error");
        return
    end
    result = app.results{app.ListBox.Value};
    if result.num_env > length(app.default_env_order)
        fprintf("plot_ver_fitness Error: More env(%d) in %s than app.default_env_order(%d)\n", result.num_env, result.user_id, length(app.default_env_order));
    end
    figure();
    num_subplots = result.num_env;
    % Note the corner case : result.num_env < length(app.default_env_order)
    env_default_idx = []; % stores the id of the env in app.default_env_order
    user_study_order = []; % stores the place of the env in user study
    order_name = "";
    if app.VerOrderCheckBox.Value % use defalut order
        order_name = "default order";
        for i = 1 : length(app.default_env_order)
            env_default_idx(i) = i;
            user_study_order(i) = find_place_in_user_study(app.default_env_order(i), result);
        end
    else
        % use the order of actual user study
        order_name = "user study order";
        for i = 1 : result.num_env
            env_default_idx(i) = find_default_idx(result.envs(i));
            user_study_order(i) = i;
        end
    end

    for i = 1 : result.num_env
        idx = env_default_idx(i);
        subplot(result.num_env, 1, i);
        plot(result.fitness(idx, :));
        env = app.default_env_order(idx);
        title(sprintf('%s - (%d)', app.default_env_order(idx), user_study_order(i)));
        xlabel('ver');
        ylabel('fitness');
    end

    %% Helper functions
    function id = find_default_idx(env_name)
        for id = 1 : length(app.default_env_order)
            if env_name == app.default_env_order(id) % both are strings
                return
            end
        end
        id = -1;
        fprintf("find_default_idx Error: couldn't find %s in default env order", env_name);
    end
    function p = find_place_in_user_study(env_name, result)
        for p = 1 : length(result.envs)
            if env_name == result.envs(p) % both are strings
                return
            end
        end
        p = -1;
        fprintf("find_place_in_user_study Error: %s didn't show up in the user study %s", env_name, result.user_id);
    end
    sgtitle(sprintf("Input of User %s - %s", result.user_id, order_name));
end
