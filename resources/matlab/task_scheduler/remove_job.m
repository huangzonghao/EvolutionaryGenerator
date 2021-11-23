function remove_job(app)
    app.jobs(app.JobsListBox.Value) = [];
    refresh_jobs_list(app);
end
