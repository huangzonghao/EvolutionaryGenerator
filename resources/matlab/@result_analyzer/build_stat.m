% TODO: why not make a stat class so that each different stat would be clear to see
% TODO: if there is archive.mat, should read it directly and build the stat
% archive.mat - archive:
%     each row: [gen_id, id, f_id1, f_id2, fitness]
%     each gen is a matrix stored in a cell. i.e. archive{1} for gen 0
% robots.mat - robots:
%     each row: [p1_gid, p1_id, p2_gid, p2_id, f_id1, f_id2, f1, f2, fitness]
%     robots is a 3d matrix: gen_size x 9 x nb_gen + 1
% robots_dump.mat - robots_dump
%     design_vector only, stored in 2d cell array. i.e. dv = robots_dump{i_gen}{i_robot}
function [stat, stat_loaded] = build_stat(result, dump_robots, orig_stat, orig_stat_loaded)
    [~, result_basename, ~] = fileparts(result.path);
    num_dim = length(result.evo_params.grid_dim);
    nb_gen = result.evo_params.nb_gen;
    archive_size = prod(result.evo_params.grid_dim);

    % robots format:
    % v1: [gid, id, p1_gid, p1_id, p2_gid, p2_id, f_id1, f_id2, f1, f2, fitness, gene]
    % v2: [gid, id, p1_gid, p1_id, p2_gid, p2_id, fitness, f_id1, ... , f_idn, f1, ... , fn, gene]
    % nb_gen + 1 because init seeds are gen 0
    % Note the robot id starts from 0, so always +1 when retriving data from matlab array
    % data goes into the table is guaranteed to be sorted
    if result.version == 1
        robots = zeros(result.evo_params.gen_size, 9, nb_gen + 1);
    end

    % robots dump format:
    % Each generation is a cell containing all robots of that generation in the order of id
    % Each robot is a an array of genome
    robots_dump = {};

    % Parentage
    stat.has_parentage = false;
    bag_file_path = fullfile(result.path, 'Bag_*.json');
    bag_file = dir(bag_file_path);
    if ~isempty(bag_file)
        if length(bag_file) > 1
            msgbox(sprintf('Error: multiple user input bag files found in %s', result_basename));
            return
        end
        fid = fopen(fullfile(bag_file.folder, bag_file.name));
        jsobj = jsondecode(fscanf(fid, '%c', inf));
        fclose(fid);
        if isfield(jsobj, 'user_seed_count')
            num_seeds = jsobj.user_seed_count;
        else
            num_seeds = jsobj.total_count;
        end
        if num_seeds > 0 && num_seeds < result.evo_params.gen_size % otherwise would be meaningless to build parentage
            stat.robot_parentage = zeros(result.evo_params.gen_size, nb_gen + 1);
            stat.robot_parentage(1 : num_seeds, 1) = 1; % user designed seeds has percentage 100%
            stat.archive_parentage = zeros(1, nb_gen + 1);
            stat.archive_parentage_over_map = zeros(1, nb_gen + 1);
            stat.population_parentage = zeros(1, nb_gen + 1);
            stat.pop_hp_fitness = zeros(1, nb_gen + 1);
            stat.pop_lp_fitness = zeros(1, nb_gen + 1);
            stat.top15_hp_fitness = zeros(1, nb_gen + 1);
            stat.top15_lp_fitness = zeros(1, nb_gen + 1);
            stat.has_parentage = true;

            top15_hp = [];
            top15_lp = [];
            tmp_parentage_map = zeros(result.evo_params.grid_dim);
        end
    end

    % TODO: how to resume from loaded stat with the new changes -- set i_start smartly
    if (orig_stat_loaded)
        stat = orig_stat;
    else
        stat.elite_robot_selection = false(result.evo_params.gen_size, nb_gen + 1); % entries of value 1 indicate the corresponding robot has made it to 10% of the archive map at some generation
        stat.robot_fitness = zeros(result.evo_params.gen_size, nb_gen + 1);
        stat.robot_longevity = double(-1) * ones(result.evo_params.gen_size, nb_gen + 1);
        stat.archive_fits = zeros(1, nb_gen + 1);
        stat.archive_std = zeros(1, nb_gen + 1);
        stat.archive_age = zeros(1, nb_gen + 1);
        stat.elite_archive_fits = zeros(1, nb_gen + 1); % mean fitness of top 10% indivs of archive after each generation
        stat.elite_archive_std = zeros(1, nb_gen + 1);
        stat.elite_archive_age = zeros(1, nb_gen + 1);
        stat.best_fits = zeros(1, nb_gen + 1); % best fitness of archive
        stat.qd_score = zeros(1, nb_gen + 1); % best fitness of archive
        stat.population_fits = zeros(1, nb_gen + 1);
        stat.coverage = zeros(1, nb_gen + 1);
        if result.version == 1
            stat.map_stat = zeros(result.evo_params.grid_dim(1), result.evo_params.grid_dim(2), nb_gen + 1);
        end

        stat.clean_archive_fits = zeros(1, nb_gen + 1);
        stat.clean_archive_std = zeros(1, nb_gen + 1);
        stat.clean_archive_age = zeros(1, nb_gen + 1);
        stat.clean_elite_archive_fits = zeros(1, nb_gen + 1); % mean fitness of top 10% indivs of archive after each generation
        stat.clean_elite_archive_fits = zeros(1, nb_gen + 1);
        stat.clean_elite_archive_age = zeros(1, nb_gen + 1);
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
            waitbar(double(i + 1) / double(nb_gen + 1), wb, sprintf("Processing %d / %d, %02d:%02d used, %02d:%02d left", i + 1, nb_gen + 1, floor(t_passed / 60), rem((t_passed), 60), floor(t_left / 60), rem(t_left, 60)));
        end

        % Load gridmaps
        % gridmap format :
        % Version 1 [gen_id, id, f_id1, f_id2, fitness]
        % Version 1 [gen_id, id, fitness, f_id1, ..., f_idn]
        curr_gen_archive = readmatrix(fullfile(result.path, strcat('/gridmaps/', num2str(i), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');

        if result.version == 1
            fitness = curr_gen_archive(:, 5);
        elseif result.version == 2
            fitness = curr_gen_archive(:, 3);
        end

        age = double(i) * ones(size(curr_gen_archive, 1), 1) - curr_gen_archive(:, 1);
        stat.archive_fits(i + 1) = mean(fitness);
        stat.archive_std(i + 1) = std(fitness);
        stat.archive_age(i + 1) = mean(age);
        [max10_fitness, max10_idx] = maxk(fitness, ceil(length(fitness) * 0.1));
        stat.elite_archive_fits(i + 1) = mean(max10_fitness);
        stat.elite_archive_std(i + 1) = std(max10_fitness);
        stat.elite_archive_age(i + 1) = mean(age(max10_idx));
        max10_gen_ids = curr_gen_archive(max10_idx, 1) + 1;
        max10_ids = curr_gen_archive(max10_idx, 2) + 1;
        stat.elite_robot_selection(sub2ind(size(stat.elite_robot_selection), max10_ids, max10_gen_ids)) = true;
        stat.coverage(i + 1) = length(fitness) / archive_size;

        if result.version == 1
            clean_fitness = curr_gen_archive(curr_gen_archive(:,3) ~= 0, 5);
            clean_age = curr_gen_archive(curr_gen_archive(:,3) ~= 0, 1);
            clean_age = double(i) * ones(size(clean_age)) - clean_age;
            stat.clean_archive_fits(i + 1) = mean(clean_fitness);
            stat.clean_archive_std(i + 1) = std(clean_fitness);
            stat.clean_archive_age(i + 1) = mean(clean_age);
            [clean_max10_fitness, clean_max10_idx] = maxk(clean_fitness, ceil(length(clean_fitness) * 0.1));
            stat.clean_elite_archive_fits(i + 1) = mean(clean_max10_fitness);
            stat.clean_elite_archive_std(i + 1) = std(clean_max10_fitness);
            stat.clean_elite_archive_age(i + 1) = mean(clean_age(clean_max10_idx));
            stat.best_fits(i + 1) = clean_max10_fitness(1);
            stat.qd_score(i + 1) = sum(clean_fitness);
        elseif result.version == 2
            stat.best_fits(i + 1) = max10_fitness(1);
            stat.qd_score(i + 1) = sum(fitness);
        end

        archive{i + 1} = curr_gen_archive;

        % Load gridstats
        if result.version == 1
            stat_mat = readmatrix(fullfile(result.path, strcat('/gridstats/', num2str(i), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
            stat_mat = stat_mat(1 : result.evo_params.grid_dim(1), 1 : result.evo_params.grid_dim(2)); % a lasy way to remove the nan values due to the trailing comma in gridstats
            stat.map_stat(:,:,i + 1) = stat_mat;
            if i > 0
                stat.map_stat(:,:,i + 1) = stat.map_stat(:,:,i + 1) + stat.map_stat(:,:,i);
            end
        end

        % process each indiv's age
        if i > 0 % TODO: see if we can remove this condition
            % Note curr_gen_archive and prev_gen_archive may have different size
            f_ids = curr_gen_archive(age == 0, 3:4);
            prev_f_ids = prev_gen_archive(:, 3:4);
            [~, dead_selection] = ismember(f_ids, prev_f_ids, 'rows');
            dead_selection = dead_selection(dead_selection ~= 0);
            dead_gen_ids = prev_gen_archive(dead_selection, 1) + 1;
            dead_ids = prev_gen_archive(dead_selection, 2) + 1;

            % A robot show up in map in gen k and get replaced in gen k + 1 would have a longevity of 1
            stat.robot_longevity(sub2ind(size(stat.robot_longevity), dead_ids, dead_gen_ids)) = double(i + 1) * ones(size(dead_gen_ids)) - dead_gen_ids;

            % If this is the final gen, kill all robot in final + 1 gen and calculate longevity again
            % Note this cannot be merged with the above process, otherwise we would lost tracking of
            % robots got replaced in the final gen
            if i == nb_gen
                dead_gen_ids = curr_gen_archive(:, 1) + 1;
                dead_ids = curr_gen_archive(:, 2) + 1;
                stat.robot_longevity(sub2ind(size(stat.robot_longevity), dead_ids, dead_gen_ids)) = double(i + 2) * ones(size(dead_gen_ids)) - dead_gen_ids;
            end
        end

        % Load robots
        % robots format from file:
        % v1: [gid, id, p1_gid, p1_id, p2_gid, p2_id, f_id1, f_id2, f1, f2, fitness, gene]
        % v2: [gid, id, p1_gid, p1_id, p2_gid, p2_id, fitness, f_id1, ... , f_idn, f1, ... , fn, gene]
        curr_gen_robot = readmatrix(fullfile(result.path, strcat('/robots/', num2str(i), '.csv')), delimitedTextImportOptions('DataLines',[1,Inf]), 'OutputType','double');
        % sort entries to make them in the order of id -- need to do this because of a stupid bug I made
        %     in the training code that caused the results to be recorded in the randomized parent order
        curr_gen_robot = sortrows(curr_gen_robot, 2);
        robots(:, 1:9, i + 1) = curr_gen_robot(:, 3:11);
        if dump_robots
            tmp_gen = {};
            for j = 1 : size(curr_gen_robot, 1)
                dv = curr_gen_robot(j, 12:end);
                tmp_gen{j} = dv(~isnan(dv));
            end
            robots_dump{i + 1} = tmp_gen;
        end
        if result.version == 1
            pop_fitness = curr_gen_robot(:, 11);
        elseif result.version == 2
            pop_fitness = curr_gen_robot(:, 7);
        end
        stat.population_fits(i + 1) = mean(pop_fitness);
        stat.robot_fitness(:, i + 1) = pop_fitness;

        if stat.has_parentage
            % Update parentage
            if i > 0
                % TODO: how to vectorize the following
                for j = 1 : result.evo_params.gen_size
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

            % get hp and lp of current generation
            tmp_hp = pop_fitness(stat.robot_parentage(:, i + 1) >= 0.5); % colmun vector
            tmp_lp = pop_fitness(stat.robot_parentage(:, i + 1) <= 0.5); % colmun vector
            stat.pop_hp_fitness(i + 1) = mean(tmp_hp);
            stat.pop_lp_fitness(i + 1) = mean(tmp_lp);

            top15_hp = maxk([top15_hp; tmp_hp], 15);
            top15_lp = maxk([top15_lp; tmp_lp], 15);
            stat.top15_hp_fitness(i + 1) = mean(top15_hp);
            stat.top15_lp_fitness(i + 1) = mean(top15_lp);
        end

        stat.processed_gen = i;
        prev_gen_archive = curr_gen_archive;
    end
    close(wb);
    save(fullfile(result.path, 'stat.mat'), 'stat', '-v7.3');
    save(fullfile(result.path, 'robots.mat'), 'robots', '-v7.3');
    save(fullfile(result.path, 'archive.mat'), 'archive', '-v7.3');
    if dump_robots
        save(fullfile(result.path, 'robots_dump.mat'), 'robots_dump', '-v7.3');
    end

    stat_loaded = true;
end
