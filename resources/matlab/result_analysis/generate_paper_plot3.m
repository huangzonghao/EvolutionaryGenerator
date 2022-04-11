function generate_paper_plot3(app)
% generate statistical curves for training progress

    if length(app.targets_to_compare) ~= 5
        msgbox('Need 5 result of the same env to generate plot');
        return
    end

    fig = figure('units','normalized','outerposition',[.05 .05 .9 .9]);
    if ~isempty(app.CompPlotNameField.Value)
        sgtitle(app.CompPlotNameField.Value, 'Interpreter', 'none');
    end

    enable_split = false;
    gens_to_remove = [500 1700];
    split_size = 20;
    tick_gap = 100;

    data_to_keep = {1:gens_to_remove(1), gens_to_remove(2)+1:2001};
    remap = {1:gens_to_remove(1), gens_to_remove(1)+split_size:2000+split_size-diff(gens_to_remove)};
    tick_marks = [0:tick_gap:gens_to_remove(1)-50, gens_to_remove(1)+split_size:100:2000+split_size-diff(gens_to_remove)];
    tick_labels = arrayfun(@(i)num2str(i), [0:tick_gap:gens_to_remove(1)-50, gens_to_remove(2):100:2000], 'uniformoutput',false);

    % Setup the plot axes
    plot_names = {'Mean Fitness', 'Best Fitness', 'QD-Score', 'Coverage (%)'};

    num_subplots = length(plot_names);
    p = {};

    for i = 1 : num_subplots
        p{i} = subplot(num_subplots, 1, i, 'NextPlot', 'add');
        % title(p{i}, plot_names{i});
        % xlabel(p{i}, 'Iteration (Batch Size 30)');
        xlim(p{i}, [0, 2000]);
        ylabel(p{i}, plot_names{i});
        set(p{i},'FontName', 'Times New Roman', 'FontSize', 10)
    end

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
        % clean_archive_fits = [];

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
            % clean_archive_fits(end + 1, :) = child_result.stat.clean_archive_fits;
        end
        coverage = coverage * 100;

        if enable_split
            for ipart = 1:length(data_to_keep)
                m = mean(archive_fits(:,data_to_keep{ipart}), 1);
                s = std(archive_fits(:,data_to_keep{ipart}), 0, 1);
                shadedErrorBar(p{1}, remap{ipart}, m, s, 'Color', plot_color, 'DisplayName', result.name);
            end
            for ipart = 1:length(data_to_keep)
                m = mean(best_fits(:,data_to_keep{ipart}), 1);
                s = std(best_fits(:,data_to_keep{ipart}), 0, 1);
                shadedErrorBar(p{2}, remap{ipart}, m, s, 'Color', plot_color, 'DisplayName', result.name);
            end
            for ipart = 1:length(data_to_keep)
                m = mean(qd_score(:,data_to_keep{ipart}), 1);
                s = std(qd_score(:,data_to_keep{ipart}), 0, 1);
                shadedErrorBar(p{3}, remap{ipart}, m, s, 'Color', plot_color, 'DisplayName', result.name);
            end
            for ipart = 1:length(data_to_keep)
                m = mean(coverage(:,data_to_keep{ipart}), 1);
                s = std(coverage(:,data_to_keep{ipart}), 0, 1);
                h = shadedErrorBar(p{4}, remap{ipart}, m, s, 'Color', plot_color, 'DisplayName', result.name);
            end
        else
            shadedErrorBar(p{1}, [], archive_fits, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
            shadedErrorBar(p{2}, [], best_fits, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
            shadedErrorBar(p{3}, [], qd_score, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
            h = shadedErrorBar(p{4}, [], coverage, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
        end

        % Legend
        this_name = result.name;
        this_name(1:strfind(this_name, '_')) = [];
        legend_entries{end+1} = ['H' this_name];
        legend_handles(end+1) = h.mainLine;
    end

    % Format split gap
    if enable_split
        for iplot = 1 : num_subplots
            ax = p{iplot};
            ylimits = ax.YLim;
            rectangle(ax, 'Position', [gens_to_remove(1), ylimits(1), split_size, ylimits(2) - ylimits(1)], ...
                      'facecolor', [.9 .9 .9], 'edgecolor','none')

            text(ax, gens_to_remove(1) + split_size / 2, ylimits(1), '//', 'horizontalalignment','center')

            ax.XTick = tick_marks;
            ax.XTickLabel = tick_labels;
            ax.XLim = [min(tick_marks), max(tick_marks)];
            % xtickangle(ax, 45);
            ax.Layer = 'top';
        end
    end

    p{3}.YAxis.Exponent = 2;
    ytickangle(p{4}, 90);
    xlabel(p{4}, 'Iteration (Batch Size 30)');
    leg = legend(legend_handles,legend_entries, 'location','southeast','orientation','horizontal');
    leg.ItemTokenSize = [20, 18];

    % uicontrol(fig, 'style','text', 'string', 'Sample Title', 'units','normalized','position',[0 .95 1 .03], ...
              % 'FontName','Times New Roman','fontsize', 12,'fontweight','Bold','background','w')

    if ~isempty(app.CompPlotNameField.Value)
        sgtitle(app.CompPlotNameField.Value, 'Interpreter', 'none', 'FontName', 'Times New Roman', 'FontSize', 12, 'FontWeight', 'Bold');
    end

    set(fig, 'units', 'inches', 'position', [0 0 4 6], 'papersize', [4 6])

    % Save
    if ~isempty(app.CompPlotNameField.Value)
        % print(fig, [app.CompPlotNameField.Value '_compare.pdf'],'-dpdf','-painters');
        exportgraphics(fig, [app.CompPlotNameField.Value '_compare.pdf']);
    end

end
