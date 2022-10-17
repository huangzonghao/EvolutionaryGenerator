function toggle_job_type(app)
    if strcmp(app.JobTypeDropDown.Value, 'new')
        app.NewJobConfigsPanel.Enable = 'On';
        app.BagFilesListBox.Enable = 'On';
        app.LoadExistingResultButton.Enable = 'Off';
    elseif strcmp(app.JobTypeDropDown.Value, 'continue')
        app.NewJobConfigsPanel.Enable = 'Off';
        app.BagFilesListBox.Enable = 'Off';
        app.LoadExistingResultButton.Enable = 'On';
    end
end
