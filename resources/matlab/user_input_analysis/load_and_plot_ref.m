function load_and_plot_ref(app, name)
    name = string(name);
    % select result and load meta info
    training_result = load_training_result(app);
    if ~training_result.loaded
        return
    end

    if name == "left"
        % TODO: too dirty -- somehow heatmap destroies the original axis
        [app.heat_axes.left_heat, fitness] = plot_gen(app, {app.left_surf, app.left_heat}, training_result, 0);
    elseif name == "right"
        [app.heat_axes.right_heat, fitness] = plot_gen(app, {app.right_surf, app.right_heat}, training_result, training_result.nb_gen);
    end

    update_plots_range(app, min(fitness(:)), max(fitness(:)));
end

function training_result = load_training_result(app)
    training_result.loaded = false;
    tmp_result_path = uigetdir(app.training_results_dir, 'EvoGen Result Dir');
    figure(app.MainFigure);
    if (tmp_result_path == 0) % User pressed cancel button
        return
    end

    evo_xml = xml2struct(fullfile(tmp_result_path, 'evo_params.xml'));

    training_result.result_path = tmp_result_path;
    training_result.nb_gen_planned = str2double(evo_xml.boost_serialization{2}.EvoParams.nb_gen_.Text);
    training_result.init_size = str2double(evo_xml.boost_serialization{2}.EvoParams.init_size_.Text);
    training_result.gen_size = str2double(evo_xml.boost_serialization{2}.EvoParams.pop_size_.Text);
    training_result.griddim_0 = str2double(evo_xml.boost_serialization{2}.EvoParams.grid_shape_.item{1}.Text);
    training_result.griddim_1 = str2double(evo_xml.boost_serialization{2}.EvoParams.grid_shape_.item{2}.Text);
    training_result.feature_description1 = evo_xml.boost_serialization{2}.EvoParams.feature_description_.item{1}.Text;
    training_result.feature_description2 = evo_xml.boost_serialization{2}.EvoParams.feature_description_.item{2}.Text;

    statusfile_id = fopen(fullfile(tmp_result_path, 'status.txt'));
    status_info = cell2mat(textscan(statusfile_id, '%d/%d%*[^\n]'));
    fclose(statusfile_id);
    training_result.nb_gen = status_info(1);
    training_result.loaded = true;
end

function [heat_axis, fitness] = plot_gen(app, target_axes, training_result, gen_to_plot)

    archive_file = fullfile(training_result.result_path, ...
                            ['/gridmaps/', num2str(gen_to_plot), '.csv']);
    archive_data = readmatrix(archive_file);

    % plot heatmap
    archive_map = zeros(training_result.griddim_0, training_result.griddim_1);
    x = archive_data(:, 3) + 1;
    y = archive_data(:, 4) + 1;
    fitness = archive_data(:, 5);
    archive_map(sub2ind(size(archive_map), x, y)) = fitness;

    target_axes{1}.select();
    surf(archive_map);
    xlabel(training_result.feature_description2); % x, y flipped in plot
    ylabel(training_result.feature_description1);
    title(['Gen ', num2str(gen_to_plot)]);

    target_axes{2}.select();
    heat_axis = heatmap(archive_map);
    xlabel(training_result.feature_description2); % x, y flipped in plot
    ylabel(training_result.feature_description1);
    title(['Gen ', num2str(gen_to_plot)]);
end
