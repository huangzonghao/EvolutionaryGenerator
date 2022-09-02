function add_job(app)
    job_config = {};
    job_config.type = app.JobTypeDropDown.Value;

    if strcmp(job_config.type, 'new')
        new_job = format_job(app, job_config);
        if isempty(new_job)
            return
        end
        nickname = new_job.nickname;
        for i = 1 : app.NumRepsEditField.Value
            new_job.nickname = strcat(nickname, '_', num2str(app.StartIndexEditField.Value + i - 1));
            app.jobs{end + 1} = new_job;
        end
    elseif strcmp(job_config.type, 'continue')
        if isempty(app.result_loaded)
            msgbox('Load an existing result first to continue training');
            return
        end
        job_config.result = app.result_loaded;
        new_job = format_job(app, job_config);
        app.jobs{end + 1} = new_job;
    end

    refresh_jobs_list(app);
end
