function launch_job_file(app)
    % TODO: currently the system call would automatically close the cmd window
    % upon finishing the task. Need to find a way to keep the window open
    cmd_str = "start python " + fullfile(app.workspace_dir, 'task_launcher.py') + " " + ...
              app.JobFilesListBox.Items{app.JobFilesListBox.Value};
    system(cmd_str);
end
