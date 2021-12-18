function run_vartest(app)
    if length(app.targets_to_compare) < 2
        msgbox('Add at least 2 results to vartest');
        return
    end

    samples = {};
    % Only use the first two results
    % for i = 1 : length(app.targets_to_compare)
    for i = 1 : 2
        sample.fits = [];
        sample.elite_fits = [];
        stat_loaded = false;
        if app.targets_to_compare{i}.isgroup
            result = app.virtual_results{app.targets_to_compare{i}.id};
        else
            result = app.results{app.targets_to_compare{i}.id};
        end
        % TODO: optimize with the loaded archive data
        if result.isgroup % virtual result
            for j = 1 : result.num_results
                child_result = app.results{result.ids(j)};
                final_gen_archive = readmatrix(fullfile(child_result.path, strcat('/gridmaps/', num2str(2000), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
                final_fits = final_gen_archive(:, 5);
                elite_final_fits = maxk(final_fits, ceil(length(final_fits) * 0.1));
                sample.fits = [sample.fits; final_fits];
                sample.elite_fits = [sample.elite_fits; elite_final_fits];
            end
        else % single result
            final_gen_archive = readmatrix(fullfile(result.path, strcat('/gridmaps/', num2str(2000), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
            final_fits = final_gen_archive(:, 5);
            elite_final_fits = maxk(final_fits, ceil(length(final_fits) * 0.1));
            sample.fits = [sample.fits; final_fits];
            sample.elite_fits = [sample.elite_fits; elite_final_fits];
        end
        samples{i} = sample;
    end

    % TODO: Plot histogram
    [H1, P1] = vartest2(samples{1}.fits, samples{2}.fits);
    [H2, P2] = vartest2(samples{1}.elite_fits, samples{2}.elite_fits);
    mbox = msgbox(sprintf("All fits have same variance\n    All fits: H %d, P %d\n    Elite fits: H %d, P %d", H1, P1, H2, P2));
    mbox.Position(3) = 300;
    mbox.Position(4) = 150;
    txt = findall(mbox, 'Type', 'Text');
    txt.FontSize = 16;
end
