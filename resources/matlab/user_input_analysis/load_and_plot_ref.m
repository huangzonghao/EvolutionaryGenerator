function load_and_plot_ref(app, name)
    name = string(name);
    % select result and load meta info
    training_result = load_training_result(app);
    if ~training_result.loaded
        return
    end

    if name == "left"
        plot_gen(app.RefLeftAxes, training_result, 0);
    elseif name == "right"
        plot_gen(app.RefRightAxes, training_result, training_result.nb_gen);
    end
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

function plot_gen(target_axes, training_result, gen_to_plot)

    archive_file = fullfile(training_result.result_path, ...
                            ['/archives/archive_', num2str(gen_to_plot), '.csv']);
    archive_data = readmatrix(archive_file);

    % plot heatmap
    archive_map = zeros(training_result.griddim_0, training_result.griddim_1);
    x = archive_data(:, 2);
    y = archive_data(:, 3);
    fitness = archive_data(:, 4);
    x = round(x * double(training_result.griddim_0 - 1)) + 1;
    y = round(y * double(training_result.griddim_1 - 1)) + 1;
    archive_map(sub2ind(size(archive_map), x, y)) = fitness;
    surf(target_axes, archive_map);
    xlabel(target_axes, training_result.feature_description2); % x, y flipped in plot
    ylabel(target_axes, training_result.feature_description1);
    title(target_axes, ['Gen ', num2str(gen_to_plot)]);
end
