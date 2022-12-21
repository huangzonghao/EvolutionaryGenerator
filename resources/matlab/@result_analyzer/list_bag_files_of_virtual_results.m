function list_bag_files_of_virtual_results(app)
    num_virtual_results = length(app.VirtualResultsListBox.Value);
    for i_virtual = 1 : num_virtual_results
        virtual_result = app.virtual_results{app.VirtualResultsListBox.Value(i_virtual)};
        num_results = virtual_result.num_results;
        bagfiles = containers.Map('KeyType','char', 'ValueType','any');;
        for i_result = 1 : num_results
            result = app.results{virtual_result.ids(i_result)};
            bag_file = 'none';
            % Exploiting the fact that there is at most one file matching the following
            % pattern
            bag_file = ls(fullfile(result.path, 'Bag_*.json'));
            if length(bag_file) == 0
                bag_file = 'none';
            end

            result_idx = regexp(result.name, '_(\d+)$', 'tokens');
            if isempty(result_idx)
                result_idx = 1; % for old naming scheme, the new scheme always has a idx suffix and starts from 0
            else
                result_idx = str2double(result_idx{1});
            end

            if bagfiles.isKey(bag_file)
                bagfiles(bag_file) = [bagfiles(bag_file), double(result_idx)];
            else
                bagfiles(bag_file) = double(result_idx);
            end
        end
        disp(sprintf('%s:', virtual_result.name));
        keys = bagfiles.keys;
        values = bagfiles.values;
        for i_bag = 1 : bagfiles.Count
            disp(strcat(keys{i_bag}, ' - ', sprintf(' %d ', values{i_bag})));
        end
    end
end
