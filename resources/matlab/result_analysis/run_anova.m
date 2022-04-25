function run_anova(app)
    if length(app.targets_to_compare) < 3
        msgbox('Add at least 3 results to anova');
        return
    end
    fits = [];
    elite_fits = [];
    for i = 1 : length(app.targets_to_compare)
        result = load_target_result(app, app.targets_to_compare{i}.isgroup, app.targets_to_compare{i}.id);
        if result.isgroup % virtual result
            for j = 1 : result.num_results
                child_result = load_target_result(app, false, result.ids(j));
                tmp_fits = [];
                tmp_elite_fits = [];
                final_gen_archive = child_result.archive{child_result.evo_params.nb_gen};
                final_fits = final_gen_archive(:, 5);
                elite_final_fits = maxk(final_fits, ceil(length(final_fits) * 0.1));
                tmp_fits = [tmp_fits; final_fits];
                tmp_elite_fits = [tmp_elite_fits; elite_final_fits];
            end
            fits = [fits tmp_fits];
            elite_fits = [elite_fits tmp_elite_fits];
        else % single result
            final_gen_archive = result.archive{result.evo_params.nb_gen};
            final_fits = final_gen_archive(:, 5);
            elite_final_fits = maxk(final_fits, ceil(length(final_fits) * 0.1));
            fits = [fits final_fits];
            elite_fits = [elite_fits elite_final_fits];
        end
    end

    p1 = anova1(fits, [], 'off');
    p2 = anova1(elite_fits, [], 'off');
    mbox = msgbox(sprintf("All fits have the same mean\n    Fits p: %d,\n    Elite fits p: %d", p1, p2));
    mbox.Position(3) = 300;
    mbox.Position(4) = 150;
    txt = findall(mbox, 'Type', 'Text');
    txt.FontSize = 16;
end
