function save_paper_plot(app)
    output_filename = fullfile(app.user_input_dir, app.ScreenshotNameField.Value);
    % print(app.paper_fig, output_filename, '-dpdf', '-fillpage');
    saveas(app.paper_fig, output_filename);
    msgbox(sprintf("Paper plot saved to %s", output_filename));
end
