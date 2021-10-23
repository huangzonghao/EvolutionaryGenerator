function plot_ver_fitness(app)
    if length(app.ListBox.Value) > 1
        msgbox("Select one user only to generate the fitness plot", "Error");
        return
    end
    result = app.results{app.ListBox.Value};
    figure();
    sgtitle(['Input of User ', result.user_id]);
    num_subplots = result.num_env;
    for i = 1 : length(app.default_env_order)
        subplot(result.num_env, 1, i);
        plot(result.fitness(i, :));
        env = app.default_env_order(i);
        counter = 1;
        for env_i = 1 : length(result.envs)
            if env == result.envs(env_i) % both are strings
                break
            end
            counter = counter + 1;
        end
        title(sprintf('%s - (%d)', app.default_env_order(i), counter));
        xlabel('ver');
        ylabel('fitness');
    end
end
