function load_result(app, result_idx_to_load)
% extra results field after loaded:
%     stat: struct of the result stat
%     archive: cell array of gen archives
%              archive format: gen_id, id, f_id1, f_id2, fitness
%     evo_params: struct containing training info of result
%                 evo_params format: nb_gen_planned, init_size, gen_size, griddim_0, griddim_1
%                                    feature_description1, feature_description2, nb_gen

    if length(app.results) == 0 || result_idx_to_load == -1
        return
    end

    for i = 1 : length(result_idx_to_load)
        result_idx = result_idx_to_load(i);
        if app.results{result_idx}.loaded
            continue
        end

        [app.results{result_idx}.stat, ~] = load_stat(app.results{result_idx}.path);
        archive_container = load(fullfile(app.results{result_idx}.path, 'archive.mat'));
        app.results{result_idx}.archive = archive_container.archive;
        app.results{result_idx}.evo_params = load_evo_params(app.results{result_idx}.path);

        app.results{result_idx}.loaded = true;
    end
end
