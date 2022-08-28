function refresh_job_files_list(app)
    app.JobFilesListBox.Items = {};
    dirs = dir(app.jobfile_dir);
    T = struct2table(dirs);
    sortedT = sortrows(T, 'datenum', 'descend');
    dirs = table2struct(sortedT);
    for i = 1 : length(dirs)
        if (dirs(i).isdir || ~verify_jobfile_name(dirs(i).name))
            continue;
        end
        app.JobFilesListBox.Items{end + 1} = dirs(i).name;
        app.JobFilesListBox.ItemsData(end + 1) = length(app.JobFilesListBox.Items);
    end
end

function valid = verify_jobfile_name(name)
    valid = false;
    startidx = regexp(name, 'Job_.*\.json');
    if ~isempty(startidx)
        valid = true;
    end
end
