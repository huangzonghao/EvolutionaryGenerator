function clean_results(app)
% Remove the memory dumps recorded during training, keep only the last 3 and the first one
    num_results = length(app.ResultsListBox.Value);
    if num_results == 0
        msgbox('Select results to clean');
        return
    end

    wb = waitbar(double(0), ['Processing 1 / ', num2str(num_results)], 'Name', 'Cleaning selected results');
    for i = 1 : num_results
        waitbar(double(i) / double(num_results), wb, sprintf("Cleaning %d / %d", i + 1, num_results));
        result = app.results{app.ResultsListBox.Value{i}};
        dump_folder = fullfile(result.path, 'dumps');
        if ~isdir(dump_folder)
            continue
        end
        % sort based on time and then leave the last five
        files = dir(dump_folder);
        files(1:2) = []; % remove '..' and '.'
        T = struct2table(files);
        sortedT = sortrows(T, 'datenum', 'descend');
        files = table2struct(sortedT);
        if length(files) > 5
            for i_file = 4 : length(files) - 1
                delete(fullfile(dump_folder, files(i_file).name));
            end
        end
    end
    close(wb);
end
