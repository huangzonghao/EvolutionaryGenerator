function feature_plot_prev_user(app)
    app.UserInputFileListBox.Value = app.UserInputFileListBox.Value(1);
    if app.UserInputFileListBox.Value > 1
        app.UserInputFileListBox.Value = app.UserInputFileListBox.Value - 1;
    else
        app.UserInputFileListBox.Value = length(app.UserInputFileListBox.Items);
    end
    plot_ver_features(app);
end
