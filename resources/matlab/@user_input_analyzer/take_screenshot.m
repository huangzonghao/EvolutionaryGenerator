function take_screenshot(app)
    ref = app.main_ref_plot;
    if isempty(ref) || ~ishandle(ref.fig)
        return
    end
    output_filename = fullfile(app.user_input_dir, app.ScreenshotNameField.Value);
    saveas(ref.fig, output_filename);
    msgbox(sprintf("Screenshot saved to %s", output_filename));
end
