function remove_job(app)
    if isempty(app.JobsListBox.Value)
        msgbox('Select a job to remove');
        return
    end
    app.jobs(app.JobsListBox.Value) = [];
    refresh_jobs_list(app);
end
