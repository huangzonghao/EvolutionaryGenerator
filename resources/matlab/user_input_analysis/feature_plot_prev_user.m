function feature_plot_prev_user(app)
    app.ListBox.Value = app.ListBox.Value(1);
    if app.ListBox.Value > 1
        app.ListBox.Value = app.ListBox.Value - 1;
    else
        app.ListBox.Value = length(app.ListBox.Items);
    end
    plot_ver_features(app);
end
