function generate_paper_plot(app)
    feature_description2 = 'Leg Length SD';
    feature_description1 = 'Body Length';

    fitness_range = [Inf, -Inf];
    app.paper_fig = figure('Position', [100, 100, 800, 800]);
    app.paper_fig.PaperSize = [8.5, 8.5];
    fig_panel = panel(app.paper_fig);
    fig_panel.pack(2, 2);
    fig_panel.margintop = 10;
    fig_panel.marginbottom = 20;
    fig_panel.marginleft = 20;
    fig_panel.marginright = 20;
    fig_panel.de.marginright = 30;
    fig_panel.de.margintop = 20;

    ground_archive = fig_panel(1, 1);
    sine_archive = fig_panel(1, 2);
    valley_archive = fig_panel(2, 1);
    update_bar = fig_panel(2, 2);


    % Ground
    update_results_enabled(app, -1);
    update_results_enabled(app, 1);

    app.archive_map(:) = nan;
    app.map_stat(:) = 0;
    for i = 1 : size(app.results_enabled, 1) % user_id
        for j = 1 : size(app.results_enabled, 2) % env_id
            if app.results_enabled(i,j) == 1
                add_to_archive(app, app.results{i}.feature(j,:,:), app.results{i}.fitness(j,:), j);
            end
        end
    end
    ground_archive.select();
    ground_hm = heatmap(app.archive_map);
    ground_hm.NodeChildren(3).YDir='normal';
    ground_hm.FontColor = [0, 0, 0];
    ground_hm.FontSize = 15;
    ground_hm.FontName = 'Times New Roman';
    ground_hm.MissingDataLabel = 'Nan';
    title('(i) Ground');
    xlabel(feature_description2); % x, y flipped in plot
    ylabel(feature_description1);

    % Sine
    update_results_enabled(app, -1);
    update_results_enabled(app, 2);

    app.archive_map(:) = nan;
    app.map_stat(:) = 0;
    for i = 1 : size(app.results_enabled, 1) % user_id
        for j = 1 : size(app.results_enabled, 2) % env_id
            if app.results_enabled(i,j) == 1
                add_to_archive(app, app.results{i}.feature(j,:,:), app.results{i}.fitness(j,:), j);
            end
        end
    end
    sine_archive.select();
    sine_hm = heatmap(app.archive_map);
    sine_hm.NodeChildren(3).YDir='normal';
    sine_hm.FontColor = [0, 0, 0];
    sine_hm.FontSize = 15;
    sine_hm.MissingDataLabel = 'Nan';
    sine_hm.FontName = 'Times New Roman';
    title('(ii) Sine');
    xlabel(feature_description2); % x, y flipped in plot
    ylabel(feature_description1);

    % Valley
    update_results_enabled(app, -1);
    update_results_enabled(app, 3);

    app.archive_map(:) = nan;
    app.map_stat(:) = 0;
    for i = 1 : size(app.results_enabled, 1) % user_id
        for j = 1 : size(app.results_enabled, 2) % env_id
            if app.results_enabled(i,j) == 1
                add_to_archive(app, app.results{i}.feature(j,:,:), app.results{i}.fitness(j,:), j);
            end
        end
    end
    valley_archive.select();
    valley_hm = heatmap(app.archive_map);
    valley_hm.NodeChildren(3).YDir='normal';
    valley_hm.FontColor = [0, 0, 0];
    valley_hm.FontSize = 15;
    valley_hm.FontName = 'Times New Roman';
    valley_hm.MissingDataLabel = 'Nan';
    title('(iii) Valley');
    xlabel(feature_description2); % x, y flipped in plot
    ylabel(feature_description1);

    % Tweak heatmaps
    ground_hm.MissingDataColor = [1, 1, 1];
    sine_hm.MissingDataColor = [1, 1, 1];
    valley_hm.MissingDataColor = [1, 1, 1];
    % Remove the excess axis labels
    for i = 2 : 20
        if mod(i, 5) ~= 0
            ground_hm.XDisplayLabels{i} = nan;
            ground_hm.YDisplayLabels{i} = nan;
            sine_hm.XDisplayLabels{i} = nan;
            sine_hm.YDisplayLabels{i} = nan;
            valley_hm.XDisplayLabels{i} = nan;
            valley_hm.YDisplayLabels{i} = nan;
        end
    end
    ground_hm.XLabel = '';
    sine_hm.XLabel = '';
    sine_hm.YLabel = '';
    colormap(app.paper_fig, 'jet');

    % Updates per bin
    update_results_enabled(app, 0);
    app.archive_map(:) = 0;
    app.map_stat(:) = 0;

    for i = 1 : size(app.results_enabled, 1) % user_id
        for j = 1 : size(app.results_enabled, 2) % env_id
            if app.results_enabled(i,j) == 1
                add_to_archive(app, app.results{i}.feature(j,:,:), app.results{i}.fitness(j,:), j);
            end
        end
    end
    update_bar.select();
    stacked_bar3(update_bar.axis, app.map_stat);
    title('(iv) Updates per Bin', 'fontweight', 'bold', 'fontsize', 15, 'FontName', 'Times New Roman');
    xlabel(feature_description2, 'fontsize', 13, 'color', [0, 0, 0], 'FontName', 'Times New Roman'); % x, y flipped in plot
    ylabel(feature_description1, 'fontsize', 13, 'color', [0, 0, 0], 'FontName', 'Times New Roman');
    zlabel('Number of robots', 'fontsize', 13, 'color', [0, 0, 0], 'FontName', 'Times New Roman');
    legend('Ground', 'Sine', 'Valley');

    % Finally adjust the color limits of plots
    c_min = min([ground_hm.ColorLimits(1), sine_hm.ColorLimits(1), valley_hm.ColorLimits(1)]);
    c_max = max([ground_hm.ColorLimits(2), sine_hm.ColorLimits(2), valley_hm.ColorLimits(2)]);
    ground_hm.ColorLimits = [c_min, c_max];
    sine_hm.ColorLimits = [c_min, c_max];
    valley_hm.ColorLimits = [c_min, c_max];

    % Save
    if ~isempty(app.PaperPlotSaveNameField.Value)
        output_filename = [app.PaperPlotSaveNameField.Value, '.pdf'];
        % Need to setup the papersize of the figure properly before getting a perfect pdf
        % print(app.paper_fig, output_filename, '-dpdf', '-painters');
        % saveas(app.paper_fig, output_filename);
        exportgraphics(app.paper_fig, output_filename);
        msgbox(sprintf("Paper plot saved to %s", output_filename));
    end
end
