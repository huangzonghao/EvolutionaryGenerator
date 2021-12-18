function run_anova(app)
    if length(app.targets_to_compare) < 3
        msgbox('Add at least 3 results to anova');
        return
    end
    fits = [];
    elite_fits = [];
    for i = 1 : length(app.targets_to_compare)
        if app.targets_to_compare{i}.isgroup
            result = app.virtual_results{app.targets_to_compare{i}.id};
        else
            result = app.results{app.targets_to_compare{i}.id};
        end
        % TODO: optimize with the loaded archive data
        if result.isgroup % virtual result
            for j = 1 : result.num_results
                child_result = app.results{result.ids(j)};
                tmp_fits = [];
                tmp_elite_fits = [];
                final_gen_archive = readmatrix(fullfile(child_result.path, strcat('/gridmaps/', num2str(2000), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
                final_fits = final_gen_archive(:, 5);
                elite_final_fits = maxk(final_fits, ceil(length(final_fits) * 0.1));
                tmp_fits = [tmp_fits; final_fits];
                tmp_elite_fits = [tmp_elite_fits; elite_final_fits];
            end
            fits = [fits tmp_fits];
            elite_fits = [elite_fits tmp_elite_fits];
        else % single result
            final_gen_archive = readmatrix(fullfile(result.path, strcat('/gridmaps/', num2str(2000), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
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
