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
    if do_clean_plot
        title(p2, 'Clean Elite Fitness');
    else
        title(p2, 'Elite Fitness');
    end
    xlabel(p2, 'generation');
    ylabel(p2, 'fitness');

    p3 = subplot(num_subplots, 1, 3, 'NextPlot', 'add');
    title(p3, 'Coverage');
    xlabel(p3, 'generation');
    ylabel(p3, 'coverage');

    p4 = subplot(num_subplots, 1, 4, 'NextPlot', 'add');
    title(p4, 'Average Parentage Percentage Per Robot');
    xlabel(p4, 'generation');
    ylabel(p4, 'parentage');

    % get each plot a different color
    plot_colors = 'brcmgk';
    % the default matlab rgb triplet
    % plot_colors = [0 0.4470 0.7410;
                   % 0.8500 0.3250 0.0980;
                   % 0.9290 0.6940 0.1250;
                   % 0.4940 0.1840 0.5560;
                   % 0.4660 0.6740 0.1880;
                   % 0.3010 0.7450 0.9330;
                   % 0.6350 0.0780 0.1840];

    for i_target_to_compare = 1 : length(app.targets_to_compare)
        if app.targets_to_compare{i_target_to_compare}.isgroup
            result = app.virtual_results{app.targets_to_compare{i_target_to_compare}.id};
        else
            result = app.results{app.targets_to_compare{i_target_to_compare}.id};
        end
        plot_color = plot_colors(rem(i_target_to_compare, length(plot_colors)) + 1);
        % plot_color = plot_colors(rem(i_target_to_compare, size(plot_colors, 1)) + 1, :);
        if ~result.isgroup
            if ~result.loaded
                load_result(app, result.id);
                result = app.results{result.id};
            end
            if do_clean_plot
                plot(p1, result.stat.clean_archive_fits, 'Color', plot_color, 'DisplayName', result.name);
                plot(p2, result.stat.clean_elite_archive_fits, 'Color', plot_color, 'DisplayName', result.name);
            else
                plot(p1, result.stat.archive_fits, 'Color', plot_color, 'DisplayName', result.name);
                plot(p2, result.stat.elite_archive_fits, 'Color', plot_color, 'DisplayName', result.name);
            end
            plot(p3, result.stat.coverage, 'Color', plot_color, 'DisplayName', result.name);
            if result.stat.has_parentage
                plot(p4, result.stat.archive_parentage, 'Color', plot_color, 'DisplayName', result.name);
            end
        else % virtual result
            coverage = [];
            archive_fits = [];
            elite_archive_fits = [];
            clean_archive_fits = [];
            clean_elite_archive_fits = [];
            archive_parentage = [];

            for i_virtual_result = 1 : result.num_results
                child_result = app.results{result.ids(i_virtual_result)};
                if ~app.results{child_result.id}.loaded
                    load_result(app, child_result.id);
                    child_result = app.results{child_result.id};
                end
                coverage(end + 1, :) = child_result.stat.coverage;
                archive_fits(end + 1, :) = child_result.stat.archive_fits;
                elite_archive_fits(end + 1, :) = child_result.stat.elite_archive_fits;
                clean_archive_fits(end + 1, :) = child_result.stat.clean_archive_fits;
                clean_elite_archive_fits(end + 1, :) = child_result.stat.clean_elite_archive_fits;
                if child_result.stat.has_parentage
                    archive_parentage(end + 1, :) = child_result.stat.archive_parentage;
                end
            end
            if do_clean_plot
                shadedErrorBar(p1, [], clean_archive_fits, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
                shadedErrorBar(p2, [], clean_elite_archive_fits, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
            else
                shadedErrorBar(p1, [], archive_fits, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
                shadedErrorBar(p2, [], elite_archive_fits, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
            end
            shadedErrorBar(p3, [], coverage, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
            if length(archive_parentage) ~= 0
                shadedErrorBar(p4, [], archive_parentage, {@mean, @std}, 'Color', plot_color, 'DisplayName', result.name);
            end
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
