function take_screenshot(app)
    if ~ishandle(app.plot_fig)
        return
    end
    output_filename = fullfile(app.user_input_dir, app.ScreenshotNameField.Value);
    saveas(app.plot_fig, output_filename);
    msgbox(sprintf("Screenshot saved to %s", output_filename));
end
