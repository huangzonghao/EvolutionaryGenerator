function analyze_body_length(app)
    num_results = length(app.ResultsListBox.Value);
    wb = waitbar(double(0), ['Processing 1 / ', num2str(num_results)], 'Name', 'Processing Selected results');
    fig = figure();
    ph = axes(fig, 'NextPlot', 'add');
    for i = 1 : num_results
        result = load_target_result(app, false, app.ResultsListBox.Value{i});
        plot_kernel(app, result, ph);
    end
    close(wb);
end

function plot_kernel(app, result, plot_handle)
    nb_gen = result.evo_params.nb_gen;
    for gen_i = 0 : nb_gen
        i = gen_i + 1;
        % curr_gen_archive = archive_file.archive{i + 1};
        curr_gen_robot = readmatrix(fullfile(result.path, strcat('/robots/', num2str(i), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
        x = curr_gen_robot(:, 13)';
        y = curr_gen_robot(:, 11)';
        scatter(plot_handle, x, y, 'filled');
        hold on;
    end
end
