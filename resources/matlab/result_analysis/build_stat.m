function [stat, stat_loaded] = build_stat(result_path, evo_params, orig_stat, orig_stat_loaded)
    [~, result_basename, ~] = fileparts(result_path);
    nb_gen = evo_params.nb_gen;
    archive_size = evo_params.griddim_0 * evo_params.griddim_1;

    % robots format:
    % [p1_gid, p1_id, p2_gid, p2_id, f_id1, f_id2, f1, f2, fitness]
    % nb_gen + 1 because init seeds are gen 0
    robots = zeros(evo_params.gen_size, 9, nb_gen + 1);

    % Parentage
    stat.has_parentage = false;
    bag_file_path = fullfile(result_path, 'Bag_*.json');
    bag_file = dir(bag_file_path);
    if ~isempty(bag_file)
        if length(bag_file) > 1
            msgbox(sprintf('Error: multiple user input bag files found in %s', result_basename));
            return
        end
        fid = fopen(fullfile(bag_file.folder, bag_file.name));
        jsobj = jsondecode(fscanf(fid, '%c', inf));
        fclose(fid);
        num_seeds = jsobj.total_count;
        if num_seeds > 0
            stat.robot_parentage = zeros(evo_params.gen_size, nb_gen + 1);
            stat.robot_parentage(1 : num_seeds, 1) = 1; % user designed seeds has percentage 100%
            stat.archive_parentage = zeros(1, nb_gen + 1);
            stat.archive_parentage_over_map = zeros(1, nb_gen + 1);
            stat.population_parentage = zeros(1, nb_gen + 1);
            stat.has_parentage = true;

            tmp_parentage_map = zeros(evo_params.griddim_0, evo_params.griddim_1);
        end
    end

    % TODO: how to resume from loaded stat with the new changes -- set i_start smartly
    if (orig_stat_loaded)
        stat = orig_stat;
    else
        stat.archive_fits = zeros(1, nb_gen + 1);
        stat.elite_archive_fits = zeros(1, nb_gen + 1); % mean fitness of top 10% indivs of archive after each generation
        stat.population_fits = zeros(1, nb_gen + 1);
        stat.coverage = zeros(1, nb_gen + 1);
        stat.map_stat = zeros(evo_params.griddim_0, evo_params.griddim_1, nb_gen + 1);

        stat.clean_archive_fits = zeros(1, nb_gen + 1);
        stat.clean_elite_archive_fits = zeros(1, nb_gen + 1); % mean fitness of top 10% indivs of archive after each generation
    end

    i_start = 0;
    stat_loaded = orig_stat_loaded;

    wb = waitbar(double(i_start + 1) / double(nb_gen + 1), ['Processing 1 / ', num2str(nb_gen + 1)], 'Name', result_basename);
    t_start = tic;
    for i = i_start : nb_gen
        if mod(i, 10) == 0
            t_passed = toc(t_start);
            t_left = t_passed / double(i - i_start) * (nb_gen - i);
            t_passed = round(t_passed);
            t_left = round(t_left);
            waitbar(double(i + 1) / double(nb_gen + 1), wb, sprintf("Processing %d / %d, %d:%d used, %d:%d left", i + 1, nb_gen + 1, floor(t_passed / 60), rem((t_passed), 60), floor(t_left / 60), rem(t_left, 60)));
        end

        % Load gridmaps
        % gridmap format : gen_id, id, f_id1, f_id2, fitness
        curr_gen_archive = readmatrix(fullfile(result_path, strcat('/gridmaps/', num2str(i), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
        fitness = curr_gen_archive(:, 5);
        clean_fitness = curr_gen_archive(curr_gen_archive(:,3) ~= 0, 5);
        stat.archive_fits(i + 1) = mean(fitness);
        stat.clean_archive_fits(i + 1) = mean(clean_fitness);
        max10_fitness = maxk(fitness, ceil(length(fitness) * 0.1));
        stat.elite_archive_fits(i + 1) = mean(max10_fitness);
        clean_max10_fitness = maxk(clean_fitness, ceil(length(clean_fitness) * 0.1));
        stat.clean_elite_archive_fits(i + 1) = mean(clean_max10_fitness);
        current_gen_pop = readmatrix(fullfile(result_path, strcat('/robots/', num2str(i), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
        pop_fitness = current_gen_pop(:, 11);
        stat.population_fits(i + 1) = mean(pop_fitness);
        stat.coverage(i + 1) = length(fitness) / archive_size;
        archive{i + 1} = curr_gen_archive;

        % Load gridstats
        stat_mat = readmatrix(fullfile(result_path, strcat('/gridstats/', num2str(i), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
        stat.map_stat(:,:,i + 1) = stat_mat(1 : evo_params.griddim_0, 1 : evo_params.griddim_1); % a lasy way to remove the nan values due to the trailing comma in gridstats
        if i > 0
            stat.map_stat(:,:,i + 1) = stat.map_stat(:,:,i + 1) + stat.map_stat(:,:,i);
        end

        % Load robots
        % robots format: gen_id, id, p1_gid, p1_id, p2_gid, p2_id, f_id1, f_id2, f1, f2, fitness
        curr_gen_robot = readmatrix(fullfile(result_path, strcat('/robots/', num2str(i), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
        % sort entries to make them in the order of id -- need to do this because of a stupid bug I made
        %     in the training code that caused the results to be recorded in the randomized parent order
        curr_gen_robot = sortrows(curr_gen_robot, 2);
        robots(:, 1:9, i + 1) = curr_gen_robot(:, 3:11);

        if stat.has_parentage
            % Update parentage
            if i > 0
                % TODO: how to vectorize the following
                for j = 1 : evo_params.gen_size
                    r = robots(j, :, i + 1);
                    % Note: always need to add 1 when using raw gen_id and id
                    stat.robot_parentage(j, i + 1) = 0.5 * (stat.robot_parentage(r(2)+1, r(1)+1) + stat.robot_parentage(r(4)+1, r(3)+1));
                end
            end

            stat.population_parentage(i + 1) = mean(stat.robot_parentage(:, i + 1));

            % now compute the parentage map
            tmp_parentage_map(:) = 0;
            % gridmap format : gen_id, id, f_id1, f_id2, fitness
            x = curr_gen_archive(:, 3) + 1; % remember matlab index starts from 1
            y = curr_gen_archive(:, 4) + 1;
            parentage_dist = stat.robot_parentage(sub2ind(size(stat.robot_parentage), curr_gen_archive(:,2) + 1, curr_gen_archive(:,1) + 1));
            tmp_parentage_map(sub2ind(size(tmp_parentage_map), x, y)) = parentage_dist;

            stat.archive_parentage(i + 1) = sum(tmp_parentage_map(:)) / size(curr_gen_archive, 1);
            stat.archive_parentage_over_map(i + 1) = sum(tmp_parentage_map(:)) / archive_size;
        end
        stat.processed_gen = i;
    end
    close(wb);
    save(fullfile(result_path, 'stat.mat'), 'stat', '-v7.3');
    save(fullfile(result_path, 'robots.mat'), 'robots', '-v7.3');
    save(fullfile(result_path, 'archive.mat'), 'archive', '-v7.3');
    stat_loaded = true;
end
