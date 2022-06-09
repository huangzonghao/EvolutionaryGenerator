function sim_configs = video_simulation_configs(env)
    sim_configs.async = false;
    sim_configs.record_frame = false;
    sim_configs.canvas_size = [1380, 270];
    sim_configs.fov = 20;
    sim_configs.time_out = 30; % TODO: should read from sim_params.xml
    if strcmp(env, 'ground')
        sim_configs.env_color = [0.9, 0.9, 0.9];
        sim_configs.camera= [5, -20, 10, 5, 0, 2];
        sim_configs.light= [0, 0, -1];
    elseif strcmp(env, 'sine')
        sim_configs.env_color = [0.8, 0.8, 0.8];
        sim_configs.camera = [0, -22, 12, 0, 0, 0];
        sim_configs.light = [1, 0, -2];
    elseif strcmp(env, 'valley')
        sim_configs.env_color = [0.8, 0.8, 0.8];
        sim_configs.camera = [-2, -15, 18, -2, 0, 0];
        % There is a second camera angle for valley
        % sim_configs.camera = [-28, 0, 4, 2, 0, -1];
        sim_configs.light = [0, 0, -1];
        sim_configs.canvas_size = [690, 270];
    else
        msgbox(['Unknown environment encountered ', env]);
    end
end
