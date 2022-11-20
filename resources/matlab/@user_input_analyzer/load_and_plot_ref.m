function load_and_plot_ref(app, name)
% Select training result to generate left and right reference plot in the main_ref_plot
% Currently left ref uses the initial population and right ref uses final population
% of the selected result.
    % select result and load meta info
    training_result = load_training_result(app);
    if ~training_result.loaded
        return
    end

    ref = app.main_ref_plot;

    name = string(name);
    if name == "left"
        fitness = plot_gen(ref.left_surf, ref.left_heat, training_result, 0);
    elseif name == "right"
        fitness = plot_gen(ref.right_surf, ref.right_heat, training_result, training_result.nb_gen);
    end

    app.main_ref_plot = ref;
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

function fitness = plot_gen(surf_obj, heat_obj, training_result, gen_to_plot)

    archive_file = fullfile(training_result.result_path, ...
                            ['/gridmaps/', num2str(gen_to_plot), '.csv']);
    archive_data = readmatrix(archive_file, delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');

    % plot heatmap
    archive_map = nan(training_result.griddim_0, training_result.griddim_1);
    x = archive_data(:, 3) + 1;
    y = archive_data(:, 4) + 1;
    fitness = archive_data(:, 5);
    archive_map(sub2ind(size(archive_map), x, y)) = fitness;
    surf_archive_map = zeros(size(archive_map));
    tmp_idx = ~isnan(archive_map);
    surf_archive_map(tmp_idx) = archive_map(tmp_idx);

    surf_obj.handle.ZData = surf_archive_map;
    xlabel(surf_obj.ax, training_result.feature_description2); % x, y flipped in plot
    ylabel(surf_obj.ax, training_result.feature_description1);
    title(surf_obj.ax, ['Gen ', num2str(gen_to_plot)]);

    heat_obj.ColorData = archive_map;
    heat_obj.XLabel = training_result.feature_description2;
    heat_obj.YLabel = training_result.feature_description1;
    heat_obj.Title = ['Gen ', num2str(gen_to_plot)];
end
