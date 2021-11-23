function load_selected_job(app)
    job = app.jobs{app.JobsListBox.Value(1)};

    app.BagFilesListBox.Value = {};
    for i = 1 : length(app.BagFilesListBox.Items)
        if strcmp(app.BagFilesListBox.Items{i}, job.bagfile)
            app.BagFilesListBox.Value = i;
            break
        end
    end
    app.EnvDropDown.Value = job.env;
    app.NumGenEditField.Value = job.num_gen;
    app.PopSizeEditField.Value = job.pop_size;
    app.SimTimeEditField.Value = job.sim_time;
    app.IgnoreRandomPopInBagCheckBox.Value = job.ignore_random_pop_in_bag;
    app.NicknameEditField.Value = job.nickname;
    app.JobCommentsTextArea.Value = convertStringsToChars(job.comments);
end
