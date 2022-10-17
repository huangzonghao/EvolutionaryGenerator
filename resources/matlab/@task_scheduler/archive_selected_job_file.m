function archive_selected_job_file(app)
    if isempty(app.JobFilesListBox.Value)
        msgbox('Select a job file to archive');
        return
    end
    archive_dir = fullfile(app.jobfile_dir, 'Done');
    if ~isfolder(archive_dir)
        mkdir(archive_dir);
    end
    fullfile(app.jobfile_dir, app.JobFilesListBox.Items{app.JobFilesListBox.Value});
    movefile(fullfile(app.jobfile_dir, app.JobFilesListBox.Items{app.JobFilesListBox.Value}), ...
             fullfile(archive_dir, app.JobFilesListBox.Items{app.JobFilesListBox.Value}));

    refresh_job_files_list(app);
end
