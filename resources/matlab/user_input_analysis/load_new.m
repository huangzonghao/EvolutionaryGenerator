function load_new(app)
    [filename, ~] = uigetfile( ...
        {'*.json','JSON (*.json)'; '*.*',  'All Files (*.*)'}, ...
        'Select a processed user input file',...
        app.user_input_dir, 'MultiSelect', 'off');

    if filename == 0 % User pressed cancel button
        return
    end
    load_raw_user_input_file(app, filename);

    % Bring main UI figure back
    figure(app.MainFigure);
end
