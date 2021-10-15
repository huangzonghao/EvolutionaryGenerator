function plot_ver_fitness(app)
    if length(app.ListBox.Value) > 1
        msgbox("Select one user only to generate the fitness plot", "Error");
        return
    end
    result = app.results{app.ListBox.Value};
    figure();
    sgtitle(['Input of User ', result.user_id]);
    num_subplots = result.num_env;
    for i = 1 : result.num_env
        subplot(result.num_env, 1, i);
        plot(result.fitness(i, :));
        title(result.envs(i));
        xlabel('ver');
        ylabel('fitness');
    end
end
