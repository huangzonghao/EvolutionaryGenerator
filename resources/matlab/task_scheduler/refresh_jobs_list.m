function refresh_jobs_list(app)
    app.JobsListBox.Items = {};
    for i = 1 : length(app.jobs)
        app.JobsListBox.Items{i} = app.jobs{i}.bagfile;
        app.JobsListBox.ItemsData(i) = i;
    end
end
