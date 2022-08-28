function add_job(app)
    new_job = format_job(app);
    nickname = new_job.nickname;
    for i = 1 : app.NumRepsEditField.Value
        new_job.nickname = strcat(nickname, '_', num2str(app.StartIndexEditField.Value + i - 1));
        app.jobs{end + 1} = new_job;
    end

    refresh_jobs_list(app);
end
