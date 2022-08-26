function refresh_jobs_list(app)
    app.JobsListBox.Items = {};
    for i = 1 : length(app.jobs)
        if ~isempty(app.jobs{i}.nickname)
            app.JobsListBox.Items{i} = app.jobs{i}.nickname;
        else
            app.JobsListBox.Items{i} = app.jobs{i}.bagfile;
        end
        app.JobsListBox.ItemsData(i) = i;
    end
end
