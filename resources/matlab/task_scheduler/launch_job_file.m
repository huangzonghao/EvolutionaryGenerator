function launch_job_file(app)
    if isempty(app.JobFilesListBox.Value)
        msgbox("Select a job file to launch");
        return
    end
    % TODO: currently the system call would automatically close the cmd window
    % upon finishing the task. Need to find a way to keep the window open
    cmd_str = "start python " + ...
              app.task_launcher_path + " " + ...
              app.trainer_exe_path + " " + ...
              fullfile(app.jobfile_dir, app.JobFilesListBox.Items{app.JobFilesListBox.Value});
    system(cmd_str);
end
