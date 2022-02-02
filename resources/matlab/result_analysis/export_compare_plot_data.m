function export_compare_plot_data(app)
    do_clean_plot = false;

    if isempty(app.CompPlotNameField.Value)
        msgbox("Error: specify a plot name");
        return
    else
        plot_name = app.CompPlotNameField.Value;
        if do_clean_plot
            plot_name = strcat(plot_name, '_Clean');
        end
    end

    plot_data = {};
    for i_target_to_compare = 1 : length(app.targets_to_compare)
        new_data = {};
        if app.targets_to_compare{i_target_to_compare}.isgroup
            result = app.virtual_results{app.targets_to_compare{i_target_to_compare}.id};
        else
            result = app.results{app.targets_to_compare{i_target_to_compare}.id};
        end
        new_data.name = result.name;
        if ~result.isgroup
            if ~result.loaded
                load_result(app, result.id);
                result = app.results{result.id};
            end
            if do_clean_plot
                new_data.archive_fits = result.stat.clean_archive_fits;
                new_data.archive_elite_fits = result.stat.clean_elite_archive_fits;
            else
                new_data.archive_fits = result.stat.archive_fits;
                new_data.archive_elite_fits = result.stat.elite_archive_fits;
            end
            new_data.coverage = result.stat.coverage;
            if result.stat.has_parentage
                new_data.archive_parentage = result.stat.archive_parentage;
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
                new_data.archive_fits = clean_archive_fits;
                new_data.archive_elite_fits = clean_elite_archive_fits;
            else
                new_data.archive_fits = archive_fits;
                new_data.archive_elite_fits = elite_archive_fits;
            end
            new_data.coverage = coverage;
            if length(archive_parentage) ~= 0
                new_data.archive_parentage = archive_parentage;
            end
        end
        plot_data{i_target_to_compare} = new_data;
    end
    root_dir = fullfile(app.result_group_path, 'plots', 'compare_plots');
    if ~isfolder(root_dir)
        mkdir(root_dir);
    end
    data_filename = fullfile(root_dir, [plot_name, '_plotdata.mat']);
    save(data_filename, 'plot_data', '-v7.3');
    msgbox(sprintf("Plot data file write to %s", data_filename));
end
