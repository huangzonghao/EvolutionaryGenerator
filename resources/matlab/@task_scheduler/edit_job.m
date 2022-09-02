function edit_job(app)
    if isempty(app.JobsListBox.Value)
        msgbox('Select a job file to edit');
        return
    end

    job_config = {};
    job_config.type = app.jobs{app.JobsListBox.Value(1)}.type;
    if strcmp(job_config.type, 'new')
        edited_job = format_job(app, 'new');
    elseif strcmp(job_config.type, 'continue')
        if isempty(app.result_loaded)
            msgbox('Load an existing result first to edit a continue job');
            return
        end
        job_config.result = app.result_loaded;
        edited_job = format_job(app, job_config);
    end
    app.jobs{app.JobsListBox.Value(1)} = edited_job;

    refresh_jobs_list(app);
end
