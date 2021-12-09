function add_new_to_compare(app, adding_virtual)
    if ~adding_virtual
        for i = 1 : length(app.ResultsListBox.Value)
            tmp_result_path = app.results{app.ResultsListBox.Value{i}}.path;
            [~, result_name, ~] = fileparts(tmp_result_path);
            % return if the result has already been added
            for tmp_i = 1 : length(app.results_to_compare)
                if ~app.results_to_compare{tmp_i}.isgroup || strcmp(app.results_to_compare{tmp_i}.name, result_name)
                    continue
                end
            end
            new_result.isgroup = false;
            new_result.name = result_name;
            new_result.full_path = tmp_result_path;

            [nickname, nickname_loaded] = load_nickname(tmp_result_path);
            if nickname_loaded
                app.CompareListBox.Items{end + 1} = nickname;
                new_result.name = nickname;
            else
                app.CompareListBox.Items{end + 1} = convertStringsToChars(result_name);
            end

            app.results_to_compare{end + 1} = new_result;
            app.CompareListBox.ItemsData(end + 1) = length(app.results_to_compare);
        end
    else
        for i = 1 : length(app.VirtualResultsListBox.Value)
            result = app.virtual_results{app.VirtualResultsListBox.Value(i)};
            for tmp_i = 1 : length(app.results_to_compare)
                if app.results_to_compare{tmp_i}.isgroup && strcmp(app.results_to_compare{tmp_i}.name, result.name)
                    continue
                end
            end
            app.results_to_compare{end + 1} = result;
            app.CompareListBox.Items{end + 1} = result.name;
            app.CompareListBox.ItemsData(end + 1) = length(app.results_to_compare);
        end
    end
end
