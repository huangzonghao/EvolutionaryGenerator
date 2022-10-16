function task_scheduler_init(app, evogen_workspace_path, evogen_exe_path, evogen_task_launcher_path)
    movegui(app.MainFigure, 'center');

    % Init paths
    app.workspace_dir = evogen_workspace_path;
    app.task_launcher_path = evogen_task_launcher_path;

    % figure out the path to the executable for training
    exe_name = 'Evolutionary_Generator';
    if (ispc)
        exe_name = strcat(exe_name, '.exe');
    end
    app.trainer_exe_path = fullfile(evogen_exe_path, exe_name);
    app.bagfile_dir = fullfile(app.workspace_dir, 'UserInput', 'Bags');
    app.jobfile_dir = fullfile(app.workspace_dir, 'Jobs');

    % Init fields
    app.JobTypeDropDown.Items{1} = 'new';
    app.JobTypeDropDown.Items{2} = 'continue';
    app.JobTypeDropDown.Value = 'new';

    app.EnvironmentDropDown.Items{1} = 'ground';
    app.EnvironmentDropDown.Items{2} = 'Sine2.obj';
    app.EnvironmentDropDown.Items{3} = 'Valley5.obj';
    app.EnvironmentDropDown.Value = 'ground';

    app.NumGenEditField.Value = 6000;
    app.PopSizeEditField.Value = 30;
    app.InitPopEditField.Value = 30;
    app.SimTimeEditField.Value = 60;
    app.SessionTimeEditField.Value = 30;
    app.NumUserInputsEditField.Value = 25;

    app.NumDimEditField.Value = 2;
    grid_dim_string = num2str([20, 20], '%d,');
    app.GridDimensionEditField.Value = grid_dim_string(1:end-1);

    refresh_bag_list(app);
end
