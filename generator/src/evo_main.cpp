#include <iostream>
#include <fstream>
#include <filesystem>
#include <chrono>

#include <sferes/gen/evo_float.hpp>
#include <sferes/modif/dummy.hpp>
#include <sferes/phen/parameters.hpp>
#include <sferes/run.hpp>

#include <sferes/fit/fit_qd.hpp>
#include <sferes/stat/qd_selection.hpp>
#include <sferes/qd/container/archive.hpp>
#include <sferes/qd/container/grid.hpp>
#include <sferes/qd/selector/uniform.hpp>

#include "sferes_eval_EvoGenEval.hpp"
#include "sferes_fit_EvoGenFitness.hpp"
#include "sferes_stat_EvoGenStat.hpp"
#include "sferes_qd_EvoGenQD.hpp"

#include "evo_paths.h"

#include "sferes_params.h"

// Setting SimulatorParams as global variable instead of SimulationManager is due to
//      later parallelizing concerns - a SimulationManager instance would be created
//      for each thread.
SimulatorParams sim_params;

int main(int argc, char **argv)
{
    // set up output dir
    time_t t = time(0);
    char time_buffer [80];
    strftime(time_buffer, 80, "%Y%m%d_%H%M%S", localtime(&t));

    std::string log_dir = Result_Output_Dir + "/EvoGen_" +
                          "P" + std::to_string(Params::pop::size) +
                          "G" + std::to_string(Params::pop::nb_gen) + "_" +
                          std::to_string(Params::qd::grid_shape(0)) + "x" +
                          std::to_string(Params::qd::grid_shape(1)) +
                          "_" + time_buffer;

    using namespace sferes;

    typedef EvoGenFitness<Params> fit_t;
    typedef gen::EvoFloat<Params::evo_float::dimension, Params> gen_t;

    typedef phen::Parameters<gen_t, fit_t, Params> phen_t;

    typedef eval::EvoGenEval<Params> eval_t;
    // typedef eval::Parallel<Params> eval_t;

    typedef boost::fusion::vector<sferes::stat::EvoGenStat<phen_t, Params> > stat_t;

    typedef modif::Dummy<> modifier_t;

    typedef qd::EvoGenMapElites<phen_t, eval_t, stat_t, modifier_t, Params> qd_t;

    std::filesystem::create_directory(log_dir); // setting up the directory from outside since we disabled the default dump

    // sim_params needs to be set before the creation of EA instance
    sim_params.SetEnv(Resource_Map_Dir + "/env3.bmp");
    // sim_params.do_viz = true;
    // sim_params.do_realtime = true;
    sim_params.AddWaypoint(0.5, 1.5, 0.3);
    sim_params.SetCamera(2.5, -1, 3, 2.5, 1.5, 0);

    sim_params.Save(log_dir + "/sim_params.csv");

    qd_t qd;
    qd.set_res_dir(log_dir);

    std::chrono::steady_clock::time_point tik = std::chrono::steady_clock::now();
    run_ea(argc, argv, qd);
    std::chrono::steady_clock::time_point tok = std::chrono::steady_clock::now();

    // generate summary
    std::ofstream data_file;

    data_file.open (log_dir + "/all_robots.csv");
    for(int i = 0; i < fitness_vec.size(); ++i){
        data_file << i + 1 << "," << fitness_vec[i];
        for(int j = 0; j < genome_vec[i].size(); ++j){
            data_file << "," << genome_vec[i][j];
        }
        data_file << std::endl;
    }
    data_file.close();

    data_file.open (log_dir + "/params.csv");
    data_file << Params::pop::nb_gen << "," // 0
              << Params::pop::initial_aleat << "," // 1
              << Params::pop::init_size << "," // 2
              << Params::pop::size << "," // 3
              << Params::pop::evogen_dump_period << "," // 4
              << Params::qd::behav_dim << "," // 5
              << Params::qd::grid_shape(0) << "," // 6
              << Params::qd::grid_shape(1) << "," // 7
              << sim_params.env_name << "," // 8
              << std::chrono::duration_cast<std::chrono::milliseconds>(tok - tik).count(); // 9
    data_file.close();

    std::cout << "Generation done" << std::endl;
    return 0;
}
