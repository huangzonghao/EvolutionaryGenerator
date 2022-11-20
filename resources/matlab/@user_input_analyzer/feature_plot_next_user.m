function feature_plot_next_user(app)
    app.UserInputFileListBox.Value = app.UserInputFileListBox.Value(1);
    if app.UserInputFileListBox.Value < length(app.UserInputFileListBox.Items)
        app.UserInputFileListBox.Value = app.UserInputFileListBox.Value + 1;
    else
        app.UserInputFileListBox.Value = 1;
    end
    plot_ver_features(app);
end
