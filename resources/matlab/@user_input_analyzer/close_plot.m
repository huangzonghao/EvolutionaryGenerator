function close_plot(app)
    ref = app.main_ref_plot;
    if ~ishandle(ref.fig)
        return
    end
    close(ref.fig);
end
