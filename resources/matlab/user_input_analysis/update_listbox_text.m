function update_listbox_text(app)
    for i = 1 : length(app.results)
        tmp_str = app.results{i}.user_id;
        % TODO: hard coded env here
        if app.results_enabled(i, 1) == 1
            tmp_str = [tmp_str, ' g'];
        end
        if app.results_enabled(i, 2) == 1
            tmp_str = [tmp_str, ' s'];
        end
        if app.results_enabled(i, 3) == 1
            tmp_str = [tmp_str, ' v'];
        end
        app.ListBox.Items{i} = tmp_str;
    end
end
