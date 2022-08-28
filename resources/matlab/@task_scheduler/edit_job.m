function edit_job(app)
    if isempty(app.JobsListBox.Value)
        msgbox('Select a job file to edit');
        return
    end

    app.jobs{app.JobsListBox.Value(1)} = format_job(app);
    refresh_jobs_list(app);
end
