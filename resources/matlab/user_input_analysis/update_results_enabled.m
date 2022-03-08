function update_results_enabled(app, env_id)
    % If there are any selected result not having the env_id env enabled, enable
    % them, otherwise disable all
    % env_id == 0 to enable all
    % env_id == -1 to disable all
    % env_id == -2 to disable all (including unselected users)

    if env_id == -2
        app.results_enabled(:, :) = 0;
        app.auto_refresh_selected_list_on_next_enabled_update = true;
    else
        ids = app.UserInputFileListBox.Value;
        if isempty(ids)
            return
        end

        if env_id == 0
            app.results_enabled(ids, :) = 1;
        elseif env_id == -1
            app.results_enabled(ids, :) = 0;
        else
            if sum(app.results_enabled(ids, env_id), 'all') == length(ids)
                app.results_enabled(ids, env_id) = 0;
            else
                app.results_enabled(ids, env_id) = 1;
            end
        end

        if (app.auto_refresh_selected_list_on_next_enabled_update)
            refresh_selected_robots_list(app);
            app.auto_refresh_selected_list_on_next_enabled_update = false;
        end
    end

    % Update the UserInputFileListBox display
    update_listbox_text(app);
end
