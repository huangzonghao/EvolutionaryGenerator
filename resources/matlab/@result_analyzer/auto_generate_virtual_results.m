function auto_generate_virtual_results(app)
    groups = containers.Map('KeyType','char', 'ValueType','any');;
    for i_result = 1 : length(app.results)
        result = app.results{i_result};

        group_name_tokens = regexp(result.name, '(\w+)_\d+$', 'tokens');
        if ~isempty(group_name_tokens)
            group_name = group_name_tokens{1}{1};
            if groups.isKey(group_name)
                groups(group_name) = [groups(group_name), i_result];
            else
                groups(group_name) = i_result;
            end
        end
    end

    keys = groups.keys;
    values = groups.values;
    for i_group = 1 : groups.Count
        new_virtual_result = {};
        new_virtual_result.isgroup = true;
        new_virtual_result.name = keys{i_group};
        new_virtual_result.ids = values{i_group};
        new_virtual_result.num_results = length(values{i_group});

        app.virtual_results{end+1} = new_virtual_result;
    end

    virtual_results = app.virtual_results;
    save(fullfile(app.result_group_path, 'virtual_results.mat'), 'virtual_results', '-v7.3');
    load_virtual_results(app);
end
