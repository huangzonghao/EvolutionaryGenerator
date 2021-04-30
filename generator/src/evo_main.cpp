#include <iostream>
#include <fstream>
#include <filesystem>
#include <chrono>

#include <sferes/gen/evo_float.hpp>
#include <sferes/modif/dummy.hpp>
#include <sferes/phen/parameters.hpp>

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
    time_t t = time(0);
    size_t rand_seed = t + ::getpid();
    std::cout<<"Seed: " << rand_seed << std::endl;
    srand(rand_seed);

    // set up output dir
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
    typedef boost::fusion::vector<sferes::stat::EvoGenStat<phen_t, Params> > stat_t;
    typedef modif::Dummy<> modifier_t;
    typedef qd::EvoGenMapElites<phen_t, eval_t, stat_t, modifier_t, Params> qd_t;

    // sim_params needs to be set before the creation of EA instance
    sim_params.SetEnv(Resource_Map_Dir + "/env3.bmp");
    // sim_params.do_viz = true;
    // sim_params.do_realtime = true;
    sim_params.AddWaypoint(0.5, 1.5, 0.3);
    sim_params.SetCamera(2.5, -1, 3, 2.5, 1.5, 0);

    qd_t qd;
    qd.set_res_dir(log_dir);
    sim_params.Save(log_dir + "/sim_params.xml");
    std::ofstream ofs;
    ofs.open(log_dir + "/progress.txt");
    ofs << "Seed: " << rand_seed << std::endl;
    ofs.close();

    std::chrono::duration<double> time_span; // in seconds
    std::chrono::steady_clock::time_point tik = std::chrono::steady_clock::now();
    qd.run(argv[0]);
    time_span = std::chrono::steady_clock::now() - tik;

    ofs.open(log_dir + "/progress.txt", std::ofstream::out | std::ofstream::app);
    ofs << "Finished in: " << time_span.count() << "s" << std::endl;
    ofs.close();

    std::cout << "Generation done" << std::endl
              << "Total run time: " << time_span.count() << "s" << std::endl;
    return 0;
}
