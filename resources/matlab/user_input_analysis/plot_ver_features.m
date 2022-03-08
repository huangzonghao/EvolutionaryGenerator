function plot_ver_features(app)
    num_results = length(app.UserInputFileListBox.Value);
    if num_results == 0
        msgbox("Select at least one user to generate the feature trace plot", "Error");
        return
    end

    if isempty(app.feature_plot_fig) || ~isvalid(app.feature_plot_fig)
        % open new plot
        app.feature_plot_fig = figure();
        app.feature_plot_fig.OuterPosition = [260, 40, 1400, 1000];
    else
        figure(app.feature_plot_fig);
    end

    % plotting only the first selected user
    app.UserInputFileListBox.Value = app.UserInputFileListBox.Value(1);
    plot_ver_features_kernel(app, app.UserInputFileListBox.Value);
end

function plot_ver_features_kernel(app, result_id)
    result = app.results{result_id};

    if result.num_env > length(app.default_env_order)
        fprintf("plot_ver_fitness Error: More env(%d) in %s than app.default_env_order(%d)\n", result.num_env, result.user_id, length(app.default_env_order));
    end

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

    % Result Structure
    % env : the order of environments
    % fitness : num_env x num_ver (env in order of app.default_env_order)
    % feature : num_env x num_ver x 2 (env in order of app.default_env_order)
    % feature_description : string array containing the feature descriptions
    subplot_num_columns = 2;
    if app.compare_group == true
        subplot_num_columns = 3;
    end
    for i = 1 : result.num_env
        idx = env_default_idx(i);

        % gather plot data
        fitness = result.fitness(idx, :)';
        features = squeeze(result.feature(idx, :, :)); % num_ver x 2
        feature_leg_x = result.feature_description(1);
        feature_leg_y = result.feature_description(2);
        feature_x = features(:, 1);
        feature_y = features(:, 2);
        len_x = feature_x(2:end) - feature_x(1:end-1);
        len_y = feature_y(2:end) - feature_y(1:end-1);
        if app.compare_group == true
            compare_fitness = result.compare.fitness(idx, :)';
            compare_features = squeeze(result.compare.feature(idx, :, :)); % num_ver x 2
            compare_feature_leg_x = result.compare.feature_description(1);
            compare_feature_leg_y = result.compare.feature_description(2);
            compare_feature_x = compare_features(:, 1);
            compare_feature_y = compare_features(:, 2);
            compare_len_x = compare_feature_x(2:end) - compare_feature_x(1:end-1);
            compare_len_y = compare_feature_y(2:end) - compare_feature_y(1:end-1);
        end

        % fitness vs versions
        sph = subplot(result.num_env, subplot_num_columns, subplot_num_columns*i-1);
        plot(fitness);
        if app.compare_group == true
            hold on;
            plot(compare_fitness);
            hold off;
            legend('Current', 'Compare');
        end
        title(sprintf('%s - (%d)', app.default_env_order(idx), user_study_order(i)));
        xlabel('Versions');
        ylabel('Fitness');

        % quiver map of features
        sph = subplot(result.num_env, subplot_num_columns, subplot_num_columns*i);
        qh = quiverwcolorbar(feature_x(1:end-1), feature_y(1:end-1), len_x, len_y, ...
                             fitness(2:end) - fitness(1:end-1), 1);

        axis equal;
        xlim([-0.1, 1.1]);
        ylim([-0.1, 1.1]);
        env = app.default_env_order(idx);
        title(sprintf('%s - (%d)', app.default_env_order(idx), user_study_order(i)));
        xlabel([feature_leg_x]);
        ylabel([feature_leg_y]);

        hold on;
        scatter(feature_x, feature_y);
        hold off;

        % quiver map of features for the compared result
        if app.compare_group == true
            sph = subplot(result.num_env, subplot_num_columns, subplot_num_columns*i - 2);
            qh = quiverwcolorbar(compare_feature_x(1:end-1), compare_feature_y(1:end-1), compare_len_x, compare_len_y, ...
                                 compare_fitness(2:end) - compare_fitness(1:end-1), 1);

            axis equal;
            xlim([-0.1, 1.1]);
            ylim([-0.1, 1.1]);
            env = app.default_env_order(idx);
            title(sprintf('%s - (%d) Compare', app.default_env_order(idx), user_study_order(i)));
            xlabel([compare_feature_leg_x]);
            ylabel([compare_feature_leg_y]);

            hold on;
            scatter(feature_x, feature_y);
            hold off;
        end
    end

    sgtitle(sprintf('%s', result.user_id));

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
