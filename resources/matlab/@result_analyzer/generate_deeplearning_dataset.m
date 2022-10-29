function generate_deeplearning_dataset(app)
    wb = waitbar(0, 'Processing dataset', 'Name', 'Generate Dataset');
    wb.Children.Title.Interpreter = 'none';

    num_results = length(app.ResultsListBox.Value);
    if num_results == 0
        msgbox('Select results to include in the dataset');
    end

    export_dir = fullfile(app.result_group_path, 'Dataset');
    if ~isfolder(export_dir)
        mkdir(export_dir);
    end

    x = [];
    y = [];
    for i_result = 1 : num_results
        result = app.results{app.ResultsListBox.Value{i_result}};
        nb_gen = result.evo_params.nb_gen;
        num_dim = length(result.evo_params.grid_dim);
        for i_gen = 1 : nb_gen
            curr_gen_robot = readmatrix(fullfile(result.path, strcat('/robots/', num2str(i_gen), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
            dv = curr_gen_robot(:, 8 + 2 * num_dim:end);
            dv(isnan(dv)) = 0;
            if size(dv, 2) < 53
                dv(end, 53) = 0; % Padding the result to the same size
            end
            x = [x; dv];

            if result.version < 2
                % v1: [gid, id, p1_gid, p1_id, p2_gid, p2_id, f_id1, f_id2, f1, f2, fitness, gene]
                pop_fitness = curr_gen_robot(:, 11);
            else
                % v2: [gid, id, p1_gid, p1_id, p2_gid, p2_id, fitness, f_id1, ... , f_idn, f1, ... , fn, gene]
                pop_fitness = curr_gen_robot(:, 7);
            end
            y = [y, pop_fitness'];

            if mod(i_gen, 200) == 0
                disp(strcat('Gen ', num2str(i_gen)));
            end
        end

        waitbar(double(i_result) / double(num_results), wb, sprintf("Processing %s (%d / %d)", result.name, i_result, num_results));
    end

    waitbar(double(1), wb, 'Writting...');
    timestamp = datestr(now,'yyyy-mm-dd_HHMMSS');
    data_x_file = fullfile(export_dir, ['dataset_x_', timestamp, '.pkl']);
    data_y_file = fullfile(export_dir, ['dataset_y_', timestamp, '.pkl']);

    mat2np(x, data_x_file, 'float64');
    mat2np(y, data_y_file, 'float64');

    close(wb);
    refresh_result_list(app);
end
