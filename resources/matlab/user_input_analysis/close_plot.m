function close_plot(app)
    if ~ishandle(app.plot_fig)
        return
    end
    close(app.plot_fig);
end
