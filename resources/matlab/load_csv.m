function [csv_mat] = load_csv(evo_gen_results_path)

[csv_filename, csv_filepath] = uigetfile( ...
    {'*.csv','CSV (*.csv)';}, 'Select a result file to load.',...
    evo_gen_results_path, 'MultiSelect', 'off');

if isequal(csv_filename, 0)
    disp('No file selected');
else
    disp(['Loading ' csv_filename]);;
end
csv_mat = readmatrix(fullfile(csv_filepath, csv_filename));

end % function
