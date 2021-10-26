function save_nickname(app, nickname)
    fid = fopen(fullfile(app.result_path, 'name.txt'), 'wt');
    fprintf(fid, nickname);
    fclose(fid);
end
