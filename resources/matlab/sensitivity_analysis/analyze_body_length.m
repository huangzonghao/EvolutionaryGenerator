function analyze_body_length(app)
    msgbox('analyzing body length');
    num_results = length(app.ResultsListBox.Value);
    wb = waitbar(double(0), ['Processing 1 / ', num2str(num_results)], 'Name', 'Processing Selected results');
    fig = figure();
    ph = axes(fig, 'NextPlot', 'add');
    for i = 1 : num_results
        result = load_target_result(app, false, app.ResultsListBox.Value{i});
        plot_kernel(app, result);
    end
    close(wb);
end

function plot_kernel(app, result, plot_handle)
    nb_gen = result.evo_params.nb_gen;
    for gen_i = 0 : nb_gen
        i = gen_i + 1;
        curr_gen_archive = archive_file.archive{i + 1};
        curr_gen_robot = readmatrix(fullfile(result_path, strcat('/robots/', num2str(i), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
        for j = 1 : size(curr_gen_robot, 1)
            robot_length = curr_gen_robot(j, k)
        end
        scatter(plot_handle, curr_gen_robot(:, 13), curr_gen_robot(:, 11), 'filled');
    end
end
