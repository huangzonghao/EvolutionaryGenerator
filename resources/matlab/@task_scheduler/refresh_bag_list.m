function refresh_bag_list(app)
    app.BagFilesListBox.Items = {};
    dirs = dir(app.bagfile_dir);
    for i = 1 : length(dirs)
        if (dirs(i).isdir || ~verify_bagfile_name(dirs(i).name))
            continue;
        end
        app.BagFilesListBox.Items{end + 1} = dirs(i).name;
        app.BagFilesListBox.ItemsData(end + 1) = length(app.BagFilesListBox.Items);
    end
end

function valid = verify_bagfile_name(name)
    valid = false;
    startidx = regexp(name, 'Bag_.*\.json');
    if ~isempty(startidx)
        valid = true;
    end
end
