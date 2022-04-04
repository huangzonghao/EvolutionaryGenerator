function generate_paper_plot3(app)
    if length(app.targets_to_compare) ~= 5
        msgbox('Need 5 result of the same env to generate plot');
        return
    end

    num_subplots = 4;
    fig = figure('units','normalized','outerposition',[.05 .05 .9 .9]);
    if ~isempty(app.CompPlotNameField.Value)
        sgtitle(app.CompPlotNameField.Value, 'Interpreter', 'none');
    end

    p1 = subplot(num_subplots, 1, 1, 'NextPlot', 'add');
    % title(p1, 'Mean Fitness');
    % xlabel(p1, 'generation');
    xlim([0, 2000]);
    ylabel(p1, 'Mean Fitness');

    p2 = subplot(num_subplots, 1, 2, 'NextPlot', 'add');
    % title(p2, 'Best Fitness');
    % xlabel(p2, 'generation');
    xlim([0, 2000]);
    ylabel(p2, 'Best Fitness');

    p4 = subplot(num_subplots, 1, 3, 'NextPlot', 'add');
    % title(p4, 'QD-Score');
    % xlabel(p4, 'generation');
    xlim([0, 2000]);
    ylabel(p4, 'QD-Score');

    p3 = subplot(num_subplots, 1, 4, 'NextPlot', 'add');
    % title(p3, 'Coverage');
    xlabel(p3, 'Generation');
    xlim([0, 2000]);
    ylabel(p3, 'Coverage(%)');


    plot_colors = [1, 0, 0;
                   1, .6, 0;
                   0, .75, 0;
                   0, .75, .75;
                   0, 0, 1];

    legend_entries = {};
    legend_handles = [];
    for i_target_to_compare = 1 : length(app.targets_to_compare)
        plot_color = plot_colors(rem(i_target_to_compare - 1, size(plot_colors, 1)) + 1, :);

        result = app.virtual_results{app.targets_to_compare{i_target_to_compare}.id};

        coverage = [];
        best_fits = [];
        qd_score = [];
        archive_fits = [];
        clean_archive_fits = [];

        for i_virtual_result = 1 : result.num_results
            child_result = app.results{result.ids(i_virtual_result)};
            if ~app.results{child_result.id}.loaded
                load_result(app, child_result.id);
                child_result = app.results{child_result.id};
            end
            coverage(end + 1, :) = child_result.stat.coverage;
            best_fits(end + 1, :) = child_result.stat.best_fits;
            qd_score(end + 1, :) = child_result.stat.qd_score;
            archive_fits(end + 1, :) = child_result.stat.archive_fits;
            clean_archive_fits(end + 1, :) = child_result.stat.clean_archive_fits;
        end

        shadedErrorBar(p1, [], archive_fits, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
        shadedErrorBar(p2, [], best_fits, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
        shadedErrorBar(p4, [], qd_score, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
        h = shadedErrorBar(p3, [], coverage, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);

        % Legend
        this_name = result.name;
        this_name(1:strfind(this_name, '_')) = [];
        legend_entries{end+1} = ['H' this_name];
        legend_handles(end+1) = h.mainLine;
    end

    leg = legend(legend_handles,legend_entries, 'location','southeast','orientation','horizontal');
    leg.ItemTokenSize = [20, 18];

    set(p1,'fontname', 'Times New Roman', 'fontsize', 10)
    set(p2,'fontname', 'Times New Roman', 'fontsize', 10)
    set(p3,'fontname', 'Times New Roman', 'fontsize', 10)
    set(p4,'fontname', 'Times New Roman', 'fontsize', 10)

    % uicontrol(fig, 'style','text', 'string', 'Sample Title', 'units','normalized','position',[0 .95 1 .03], ...
              % 'FontName','Times New Roman','fontsize', 12,'fontweight','Bold','background','w')

    if ~isempty(app.CompPlotNameField.Value)
        sgtitle(app.CompPlotNameField.Value, 'Interpreter', 'none', 'FontName', 'Times New Roman', 'FontSize', 12, 'FontWeight', 'Bold');
    end

    set(fig, 'units', 'inches', 'position', [0 0 4 6], 'papersize', [4 6])

    % Save
    print(fig, [app.CompPlotNameField.Value '_compare.pdf'],'-dpdf','-painters');

end
