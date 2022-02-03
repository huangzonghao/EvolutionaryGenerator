function save_paper_plot(app)
    output_filename = fullfile(app.user_input_dir, app.ScreenshotNameField.Value);
    % Need to setup the papersize of the figure properly before getting a perfect pdf
    print(app.paper_fig, output_filename, '-dpdf', '-painters');
    % saveas(app.paper_fig, output_filename);
    msgbox(sprintf("Paper plot saved to %s", output_filename));
end
