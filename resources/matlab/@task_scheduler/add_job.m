function add_job(app)
    if isempty(app.BagFilesListBox.Value)
        new_job.bagfile = "";
    else
        new_job.bagfile = app.BagFilesListBox.Items{app.BagFilesListBox.Value};
    end
    new_job.env = app.EnvironmentDropDown.Value;
    new_job.num_gen = app.NumGenEditField.Value;
    new_job.pop_size = app.PopSizeEditField.Value;
    new_job.sim_time = app.SimTimeEditField.Value;
    new_job.comments = string(app.JobCommentsTextArea.Value);
    new_job.ignore_random_pop_in_bag = app.IgnoreRandomPopInBagCheckBox.Value;
    nickname = app.NicknameEditField.Value;
    num_dim = app.NumDimEditField.Value;
    dim_array = str2num(app.GridDimensionEditField.Value);
    if num_dim ~= length(dim_array)
        msgbox("Grid dimension and the number of bins of each dimension doesn't match. Cannot add job");
        return
    end
    new_job.grid_dim = dim_array;

    % functional fields
    new_job.num_runs = 0;
    new_job.done = false;

    for i = 1 : app.NumRepsEditField.Value
        new_job.nickname = strcat(nickname, '_', num2str(app.StartIndexEditField.Value + i - 1));
        app.jobs{end + 1} = new_job;
    end

    refresh_jobs_list(app);
end
