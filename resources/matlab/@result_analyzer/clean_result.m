function clean_result(result)
% Remove the memory dumps recorded during training, keep only the last 3 and the first one

    dump_folder = fullfile(result.path, 'dumps');
    if ~isdir(dump_folder)
        return
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
