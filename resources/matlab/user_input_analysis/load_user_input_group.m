function load_user_input_group(app)
    new_group.path = uigetdir(app.user_input_dir, 'EvoGen User Input Group Dir');
    if new_group.path == 0
        return
    end
    [~, new_group.name, ~] = fileparts(new_group.path);
    app.UserInputGroupNameLabel.Text = new_group.name;
    app.user_input_group = new_group;

    figure(app.MainFigure);
    refresh_raw_user_input_list(app);
end
