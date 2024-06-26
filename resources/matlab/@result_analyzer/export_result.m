function export_result(result, dest_path)
% export a single result to dest_path
% result: the result struct
% dest_path: path to the dest folder. The result will be placed in dest_path/result_basename

dest_result_dir = fullfile(dest_path, result.basename);
if isfolder(dest_result_dir)
    msgbox(sprintf("Error: destination folder exists -- %s", dest_result_dir));
    return
end
mkdir(dest_result_dir);
copyfile(fullfile(result.path, 'archive.mat'), dest_result_dir);
copyfile(fullfile(result.path, 'robots.mat'), dest_result_dir);
copyfile(fullfile(result.path, 'stat.mat'), dest_result_dir);
copyfile(fullfile(result.path, 'name.txt'), dest_result_dir);
copyfile(fullfile(result.path, 'evo_params.xml'), dest_result_dir);
copyfile(fullfile(result.path, 'status.txt'), dest_result_dir);

robot_dump_file = fullfile(result.path, 'robots_dump.mat');
if isfile(robot_dump_file)
    copyfile(robot_dump_file, dest_result_dir);
end
version_file = fullfile(result.path, 'version.txt');
if isfile(version_file)
    copyfile(version_file, dest_result_dir);
end
end
