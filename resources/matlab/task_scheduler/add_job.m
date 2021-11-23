function add_job(app)
    if isempty(app.BagFilesListBox.Value)
        new_job.bagfile = "";
    else
        new_job.bagfile = app.BagFilesListBox.Items{app.BagFilesListBox.Value};
    end
    new_job.env = app.EnvDropDown.Value;
    new_job.num_gen = app.NumGenEditField.Value;
    new_job.pop_size = app.PopSizeEditField.Value;
    new_job.sim_time = app.SimTimeEditField.Value;
    new_job.nickname = app.NicknameEditField.Value;
    new_job.comments = string(app.JobCommentsTextArea.Value);
    new_job.ignore_random_pop_in_bag = app.IgnoreRandomPopInBagCheckBox.Value;

    % functional fields
    new_job.num_runs = 0;
    new_job.done = false;

    app.jobs{end + 1} = new_job;

    if app.NumRepsEditField.Value > 1
        orig_nickname = new_job.nickname;
        for i = 2 : app.NumRepsEditField.Value
            new_job.nickname = strcat(orig_nickname, '_', num2str(i));
            app.jobs{end + 1} = new_job;
        end
    end

    refresh_jobs_list(app);
end
