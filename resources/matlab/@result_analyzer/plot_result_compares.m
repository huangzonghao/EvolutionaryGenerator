function plot_result_compares(app, do_clean_plot)
    if length(app.targets_to_compare) == 0 && ~app.compare_plot_config.plot_to_file
        msgbox('Add results to compare');
        return
    end

    num_subplots = 4;
    fig = figure('units','normalized','outerposition',[.05 .05 .9 .9]);
    if app.compare_plot_config.plot_to_file
        fig.Visible = 'off';
    end
    if ~isempty(app.CompPlotNameField.Value)
        tmp_title = app.CompPlotNameField.Value;
        if do_clean_plot
            tmp_title = strcat(tmp_title, '_Clean');
        end
        sgtitle(tmp_title, 'Interpreter', 'none');
    end

    p1 = subplot(num_subplots, 1, 1, 'NextPlot', 'add');
    if do_clean_plot
        title(p1, 'Clean Fitness');
    else
        title(p1, 'Fitness');
    end
    xlabel(p1, 'generation');
    ylabel(p1, 'fitness');

    p2 = subplot(num_subplots, 1, 2, 'NextPlot', 'add');
    title(p2, 'Best Fitness');
    xlabel(p2, 'generation');
    ylabel(p2, 'fitness');

    p3 = subplot(num_subplots, 1, 3, 'NextPlot', 'add');
    title(p3, 'Coverage');
    xlabel(p3, 'generation');
    ylabel(p3, 'coverage');

    p4 = subplot(num_subplots, 1, 4, 'NextPlot', 'add');
    title(p4, 'QD-Score');
    xlabel(p4, 'generation');
    ylabel(p4, 'QD-Score');

    % get each plot a different color
    % plot_colors = 'brcmgk';
    plot_colors = [1, 0, 0;
                   1, .6, 0;
                   0, .75, 0;
                   0, .75, .75;
                   0, 0, 1];
    % the default matlab rgb triplet
    % plot_colors = [0 0.4470 0.7410;
                   % 0.8500 0.3250 0.0980;
                   % 0.9290 0.6940 0.1250;
                   % 0.4940 0.1840 0.5560;
                   % 0.4660 0.6740 0.1880;
                   % 0.3010 0.7450 0.9330;
                   % 0.6350 0.0780 0.1840];

    for i_target_to_compare = 1 : length(app.targets_to_compare)
        result = load_target_result(app, app.targets_to_compare{i_target_to_compare}.isgroup, app.targets_to_compare{i_target_to_compare}.id);
        % plot_color = plot_colors(rem(i_target_to_compare, length(plot_colors)) + 1);
        plot_color = plot_colors(rem(i_target_to_compare - 1, size(plot_colors, 1)) + 1, :);
        if ~result.isgroup
            if do_clean_plot
                plot(p1, result.stat.clean_archive_fits, 'Color', plot_color, 'DisplayName', result.name);
            else
                plot(p1, result.stat.archive_fits, 'Color', plot_color, 'DisplayName', result.name);
            end
            plot(p2, result.stat.best_fits, 'Color', plot_color, 'DisplayName', result.name);
            plot(p3, result.stat.coverage, 'Color', plot_color, 'DisplayName', result.name);
            plot(p4, result.stat.qd_score, 'Color', plot_color, 'DisplayName', result.name);
        else % virtual result
            coverage = [];
            best_fits = [];
            qd_score = [];
            archive_fits = [];
            clean_archive_fits = [];

            for i_virtual_result = 1 : result.num_results
                child_result = load_target_result(app, false, result.ids(i_virtual_result));
                coverage(end + 1, :) = child_result.stat.coverage;
                best_fits(end + 1, :) = child_result.stat.best_fits;
                qd_score(end + 1, :) = child_result.stat.qd_score;
                archive_fits(end + 1, :) = child_result.stat.archive_fits;
                clean_archive_fits(end + 1, :) = child_result.stat.clean_archive_fits;
            end
            if do_clean_plot
                shadedErrorBar(p1, [], clean_archive_fits, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
            else
                shadedErrorBar(p1, [], archive_fits, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
            end
            shadedErrorBar(p2, [], best_fits, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
            shadedErrorBar(p3, [], coverage, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
            shadedErrorBar(p4, [], qd_score, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
        end
    end

    if length(app.targets_to_compare) < 10
        legend(p1, 'Interpreter', 'none');
        legend(p2, 'Interpreter', 'none');
        legend(p3, 'Interpreter', 'none', 'Location', 'SouthEast');
        legend(p4, 'Interpreter', 'none', 'Location', 'SouthEast');
    end

   if app.compare_plot_config.plot_to_file
       for i_format = 1 : length(app.compare_plot_config.plot_format)
           saveas(fig, fullfile(app.compare_plot_config.plot_dir, [tmp_title, '.', app.compare_plot_config.plot_format{i_format}]));
       end
       close(fig);
   end
end
