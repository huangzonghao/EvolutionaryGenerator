function pack_result(result_path)
% Keep only the initial and final memory dump of the result and pack the result
% to the selected output path
    [group_path, result_basename, ~] = fileparts(result_path);
    cmd_str = "tar -czf " + result_path + ".tar.gz -C " + group_path + " " +  result_basename;
    system(cmd_str);
end
