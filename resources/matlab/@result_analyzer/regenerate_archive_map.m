function regenerate_archive_map(app)
    if isempty(app.current_result) || ~app.EnableResultEditCheckBox.Value
        msgbox('Select a result and enable archive edit first to delete a robot from archive');
        return
    end
    regenerate_archive_map_kernel(app, app.current_result.id);
    msgbox('Archive regenerated and saved');
end
