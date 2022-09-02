function save_schedule_file(app)
    jsobj.job_count = length(app.jobs);
    jsobj.current_job = 1;
    jsobj.group_name = app.GroupNameEditField.Value;
    jsobj.group_comments = string(app.GroupCommentsTextArea.Value);
    jsobj.session_time = app.SessionTimeEditField.Value;
    jsobj.timestamp = datestr(now,'yyyy-mm-dd HH:MM:SS');

    for i = 1 : jsobj.job_count
        jsobj.(['j', num2str(i)]) = app.jobs{i};
    end

    % Change log
    % 1.1: add ignore_random_pop_in_bag
    % 1.2: add session_time
    % 1.3: add grid_dim and number of bins per dimension
    % 1.4: add 'continue' job
    jsobj.format_ver = '1.4';

    middlename = '';
    if ~isempty(app.OutputFileNameEditField.Value)
        middlename = strcat(app.OutputFileNameEditField.Value, '_');
    end
    filename = strcat(fullfile(app.jobfile_dir, strcat('Job_', middlename, datestr(now, 'yyyymmdd_HHMMSS'))), '.json');
    new_file_spec = fopen(filename, "wt");
    fprintf(new_file_spec, jsonencode(jsobj, 'PrettyPrint', true));
    fclose(new_file_spec);

    refresh_job_files_list(app);
    msgbox(['Job file saved to ', filename]);
    app.OutputFileNameEditField.Value = string.empty;
end