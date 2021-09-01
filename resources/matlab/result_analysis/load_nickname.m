function [nickname, success] = load_nickname(result_path)
    success = false;
    nickname = "";
    if isfile(fullfile(result_path, 'name.txt'))
        fid = fopen(fullfile(result_path, 'name.txt'));
        nickname = fscanf(fid, '%s');
        fclose(fid);
        success = true;
    end
end
