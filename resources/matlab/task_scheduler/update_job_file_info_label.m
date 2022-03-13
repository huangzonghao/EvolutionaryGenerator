function update_job_file_info_label(app)
% load the selected job file and print out the basic information
    select_file = fullfile(app.jobfile_dir, app.JobFilesListBox.Items{app.JobFilesListBox.Value});
    fid = fopen(select_file);
    jsobj = jsondecode(fscanf(fid, '%c', inf));
    fclose(fid);

    ver = str2double(jsobj.format_ver);
    if ver < 1.2 % no session_time field
        app.JobFileInfoLabel.Text = ...
            sprintf(['Group Name:\n\t%s\n', ...
                     'Current Job:\n\t%d / %d\n', ...
                     'Time Created:\n\t%s\n'], ...
                    jsobj.group_name, ...
                    jsobj.current_job, jsobj.job_count, ...
                    jsobj.timestamp);
    else
        app.JobFileInfoLabel.Text = ...
            sprintf(['Group Name:\n\t%s\n', ...
                     'Current Job:\n\t%d / %d\n', ...
                     'Time Created:\n\t%s\n', ...
                     'Session Time:\n\t%d min\n'], ...
                    jsobj.group_name, ...
                    jsobj.current_job, jsobj.job_count, ...
                    jsobj.timestamp, ...
                    jsobj.session_time);
    end
end
