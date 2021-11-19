function remove_job(app)
    app.JobsListBox.Value
    app.jobs(app.JobsListBox.Value) = [];

    refresh_jobs_list(app);
end
