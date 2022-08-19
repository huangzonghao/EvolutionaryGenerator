% Enable app.UpdateFitAfterSim to update the recorded fitness in database when
% the evaluated fitness differs the recorded fitness by more than 10%.
function simulate_from_archive_map(app)
    % Note here in CG, x goes from left to right and y goes from
    % top to bottom -- x is column index, y is row index

    time_out = app.SimTimeEditField.Value;
    if time_out < 0
        msgbox("Error: negative simulation time");
        return
    end

    result = app.current_result;

    % Note the XY has been flipped already in gui layout
    fid_x = str2double(app.RobotIDXField.Value);
    fid_y = str2double(app.RobotIDYField.Value);
    if isnan(fid_x) || isnan(fid_y) || fid_x <= 0 || ...
       fid_x > result.evo_params.grid_dim(1) || fid_y <=0 || fid_y > result.evo_params.grid_dim(2)
        msgbox(sprintf("Error: Invalid robot coord (%d, %d)", fid_y, fid_x));
        return
    end

    id_in_archive = app.archive_ids(fid_x, fid_y);
    if (id_in_archive == 0)
        msgbox("Error: Cell (" + app.RobotIDXField.Value + ", " + app.RobotIDYField.Value + ") of Gen " + num2str(app.current_gen) + " empty");
        return
    end

    current_gen = app.current_gen;
    current_gen_archive = result.archive{current_gen + 1};
    robot_gen = current_gen_archive(id_in_archive, 1);
    robot_id = current_gen_archive(id_in_archive, 2);
    old_fitness = current_gen_archive(id_in_archive, 5);

    sim_configs = video_simulation_configs(result.env);
    sim_configs.result_id = result.id;
    sim_configs.gen_id = robot_gen;
    sim_configs.robot_id = robot_id;
    sim_configs.time_out = time_out;
    sim_configs.robot_color = [1, 0.0, 0.0];
    % sim_configs.canvas_size = [960, 360];
    % sim_configs.camera = [0, -12, 10, 0, 0, 0];
    % sim_configs.async = true;

    sim_report = simulate_robot(app, sim_configs);
    if sim_report.done
        % Only update the evaluated fitness if off by 10%
        if app.EnableResultEditCheckBox.Value && ...
           app.UpdateFitAfterSim.Value && ...
           abs(old_fitness - sim_report.fitness) > abs(old_fitness) * 0.1

            load_result_robots(app, result.id);
            app.results{result.id}.archive{current_gen + 1}(id_in_archive, 5) = sim_report.fitness;
            app.results{result.id}.robots(robot_id + 1, 9, robot_gen + 1) = sim_report.fitness;
            app.current_result.archive = app.results{result.id}.archive;
            app.current_result.robots = app.results{result.id}.robots;
            archive = app.current_result.archive;
            robots = app.current_result.robots;
            save(fullfile(result.path, 'robots.mat'), 'robots', '-v7.3');
            save(fullfile(result.path, 'archive.mat'), 'archive', '-v7.3');
            msgbox(sprintf("Fitness updated from %.4f to %.4f", old_fitness, sim_report.fitness));
            plot_gen_all(app);
        else
            msgbox(['Fitness: ', num2str(sim_report.fitness)]);
        end
    else
        msgbox('No fitness reported');
    end
end
