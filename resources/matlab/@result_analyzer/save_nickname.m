function save_nickname(app)
    if isempty(app.NickNameField.Value)
        return
    end
    num_results = length(app.ResultsListBox.Value);
    if num_results == 0
        msgbox('Select results to update nicknames');
        return
    end

    if num_results == 1
        result_path = app.results{app.ResultsListBox.Value{1}}.path;
        fid = fopen(fullfile(result_path, 'name.txt'), 'wt');
        fprintf(fid, app.NickNameField.Value);
        fclose(fid);
    else
        for i = 1 : num_results
            result = app.results{app.ResultsListBox.Value{i}};
            % To get the numeric index
            % result_idx = regexp(result.name, '_(\d+)$', 'tokens');
            % result_idx = str2double(result_idx{1})
            result_idx_str = regexp(result.name, '_\d+$', 'match');
            result_idx_str = result_idx_str{1};
            if ~isempty(result_idx_str)
                new_name = strcat(app.NickNameField.Value, result_idx_str);
            else
                new_name = app.NickNameField.Value;
            end

            fid = fopen(fullfile(result.path, 'name.txt'), 'wt');
            fprintf(fid, new_name);
            fclose(fid);
        end
    end

    app.NickNameField.Value = string.empty;
    refresh_result_list(app, 'ForceUpdate', true);
end
