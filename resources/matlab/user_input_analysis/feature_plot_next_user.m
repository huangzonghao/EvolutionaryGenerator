function feature_plot_next_user(app)
    app.ListBox.Value = app.ListBox.Value(1);
    if app.ListBox.Value < length(app.ListBox.Items)
        app.ListBox.Value = app.ListBox.Value + 1;
    else
        app.ListBox.Value = 1;
    end
    plot_ver_features(app);
end
