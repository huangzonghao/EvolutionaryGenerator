function job = format_job(app)
    % TODO:add the following so that we can fully retire sim_params and evo_params
    % enable_output_
    % init_size
    % progress_dump_period
    % ouput_write_peroid
    % output_all_robots
    % phen_data_min_
    % phen_data_max_
    %
    % env_name
    % env_dir
    % parts_dir
    %
    % The other fields are not relvent to the training, but mostly for the visualization

    if isempty(app.BagFilesListBox.Value)
        job.bagfile = "";
    else
        job.bagfile = app.BagFilesListBox.Items{app.BagFilesListBox.Value};
    end
    job.env = app.EnvironmentDropDown.Value;
    job.num_gen = app.NumGenEditField.Value;
    job.pop_size = app.PopSizeEditField.Value;
    job.sim_time = app.SimTimeEditField.Value;
    job.comments = string(app.JobCommentsTextArea.Value);
    job.ignore_random_pop_in_bag = app.IgnoreRandomPopInBagCheckBox.Value;
    job.nickname = app.NicknameEditField.Value;
    num_dim = app.NumDimEditField.Value;
    dim_array = str2num(app.GridDimensionEditField.Value);
    if num_dim ~= length(dim_array)
        msgbox("Grid dimension and the number of bins of each dimension doesn't match. Cannot add job");
        return
    end
    job.grid_dim = dim_array;

    % functional fields
    job.num_runs = 0;
    job.done = false;
end
