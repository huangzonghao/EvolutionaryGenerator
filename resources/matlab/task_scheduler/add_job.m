function add_job(app)
    new_job.bagfile = app.BagFilesListBox.Items{app.BagFilesListBox.Value};
    new_job.env = app.EnvDropDown.Value;
    new_job.num_gen = app.NumGenEditField.Value;
    new_job.pop_size = app.PopSizeEditField.Value;
    new_job.sim_time = app.SimTimeEditField.Value;
    new_job.nickname = app.NicknameEditField.Value;
    new_job.comments = string(app.JobCommentsTextArea.Value);

    % functional fields
    new_job.num_runs = 0;
    new_job.done = false;

    app.jobs{end + 1} = new_job;

    refresh_jobs_list(app);
end
