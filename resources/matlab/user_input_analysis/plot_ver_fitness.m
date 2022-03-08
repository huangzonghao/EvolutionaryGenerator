function plot_ver_fitness(app)
    num_results = length(app.UserInputFileListBox.Value);
    if num_results == 0
        msgbox("Select at least one user to generate the fitness plot", "Error");
        return
    end
    if num_results < 5
        num_cols = num_results;
    else
        num_cols = 5;
    end

    num_rows = ceil(num_results / num_cols);
    new_fig = figure();
    p = panel(new_fig);
    p.pack(num_rows, num_cols)
    counter = 1;
    for nr = 1 : num_rows
        for nc = 1 : num_cols
            if counter > num_results
                return
            end
            plot_ver_fitness_kernel(app, p(nr, nc), app.UserInputFileListBox.Value(counter));
            counter = counter + 1;
        end
    end
end

function plot_ver_fitness_kernel(app, p, result_id)
    result = app.results{result_id};
    if result.num_env > length(app.default_env_order)
        fprintf("plot_ver_fitness Error: More env(%d) in %s than app.default_env_order(%d)\n", result.num_env, result.user_id, length(app.default_env_order));
    end
    p.pack(result.num_env,1);
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
        % subplot(result.num_env, 1, i);
        p(i, 1).select();

        plot(result.fitness(idx, :));
        if app.compare_group == true
            hold on;
            plot(result.compare.fitness(idx, :));
            hold off;
        end

        env = app.default_env_order(idx);
        xlim([1, 11]); % TODO: hard coded here
        % ylim([]) % TODO: how to make the ylim be the same through all users of the same env?
        title(sprintf('%s - (%d)', app.default_env_order(idx), user_study_order(i)));
    end
    p.xlabel(['ver - ', result.user_id]);
    p.ylabel(['fitness - ', result.user_id]);

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
    function place = find_place_in_user_study(env_name, result)
        for place = 1 : length(result.envs)
            if env_name == result.envs(place) % both are strings
                return
            end
        end
        place = -1;
        fprintf("find_place_in_user_study Error: %s didn't show up in the user study %s", env_name, result.user_id);
    end
end
