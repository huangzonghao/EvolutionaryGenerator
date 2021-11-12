function [stat, stat_loaded] = build_stat(result_path, evo_params, orig_stat, orig_stat_loaded)
    [~, result_basename, ~] = fileparts(result_path);
    nb_gen = evo_params.nb_gen;
    archive_size = evo_params.griddim_0 * evo_params.griddim_1;
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

    stat_file = fullfile(result_path, 'stat.mat');

    wb = waitbar(double(i_start + 1) / double(nb_gen + 1), ['Processing 1 / ', num2str(nb_gen + 1)], 'Name', result_basename);
    for i = i_start : nb_gen
        if mod(i, 10) == 0
            waitbar(double(i + 1) / double(nb_gen + 1), wb, ['Processing ', num2str(i + 1), ' / ', num2str(nb_gen + 1)]);
        end
        curr_gen_archive = readmatrix(fullfile(result_path, strcat('/gridmaps/', num2str(i), '.csv')));
        fitness = curr_gen_archive(:, 5);
        clean_fitness = curr_gen_archive(curr_gen_archive(:,3) ~= 0, 5);
        stat.archive_fits(i + 1) = mean(fitness);
        stat.clean_archive_fits(i + 1) = mean(clean_fitness);
        max10_fitness = maxk(fitness, ceil(length(fitness) * 0.1));
        stat.elite_archive_fits(i + 1) = mean(max10_fitness);
        clean_max10_fitness = maxk(clean_fitness, ceil(length(clean_fitness) * 0.1));
        stat.clean_elite_archive_fits(i + 1) = mean(clean_max10_fitness);
        current_gen_pop = readmatrix(fullfile(result_path, strcat('/robots/', num2str(i), '.csv')));
        pop_fitness = current_gen_pop(:, 11);
        stat.population_fits(i + 1) = mean(pop_fitness);
        stat.coverage(i + 1) = length(fitness) / archive_size;

        if i == 0
            stat.map_stat(:,:,i + 1) = readmatrix(fullfile(result_path, strcat('/gridstats/', num2str(i), '.csv')));
        else
            stat.map_stat(:,:,i + 1) = stat.map_stat(:,:,i) + readmatrix(fullfile(result_path, strcat('/gridstats/', num2str(i), '.csv')));
        end
    end
    close(wb);
    save(stat_file, 'stat');
    stat_loaded = true;
end
