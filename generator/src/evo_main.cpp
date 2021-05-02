#include <iostream>
#include <fstream>
#include <filesystem>
#include <chrono>

#include <sferes/gen/evo_float.hpp>
#include <sferes/phen/parameters.hpp>
#include <sferes/modif/dummy.hpp>

#include "sferes_fit_EvoGenFitness.hpp"
#include "sferes_eval_EvoGenEval.hpp"
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
    using namespace sferes;

    typedef EvoGenFitness<Params> fit_t;
    typedef gen::EvoFloat<Params::evo_float::dimension, Params> gen_t;
    typedef phen::Parameters<gen_t, fit_t, Params> phen_t;
    typedef eval::EvoGenEval<Params> eval_t;
    typedef boost::fusion::vector<sferes::stat::EvoGenStat<phen_t, Params> > stat_t;
    typedef modif::Dummy<> modifier_t;
    typedef qd::EvoGenMapElites<phen_t, eval_t, stat_t, modifier_t, Params> qd_t;

    if (argc == 2) {
        std::filesystem::path res_path(argv[1]);
        sim_params.Load(res_path.parent_path().parent_path().string() + "/sim_params.xml");
        qd_t qd;
        qd.resume(res_path.string());
        std::cout << "Done" << std::endl;
        return 0;
    }

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

    // sim_params needs to be set before the creation of EA instance
    sim_params.SetEnv(Resource_Map_Dir + "/env3.bmp");
    // sim_params.do_viz = true;
    // sim_params.do_realtime = true;
    sim_params.AddWaypoint(0.5, 1.5, 0.3);
    sim_params.SetCamera(2.5, -1, 3, 2.5, 1.5, 0);

    qd_t qd;
    qd.set_res_dir(log_dir);
    sim_params.Save(log_dir + "/sim_params.xml");

    std::chrono::duration<double> time_span; // in seconds
    std::chrono::steady_clock::time_point tik = std::chrono::steady_clock::now();
    qd.run(argv[0]);
    time_span = std::chrono::steady_clock::now() - tik;

    std::ofstream ofs;
    ofs.open(log_dir + "/progress.txt", std::ofstream::out | std::ofstream::app);
    ofs << "Finished in: " << time_span.count() << "s" << std::endl;
    ofs.close();

    std::cout << "Generation done" << std::endl
              << "Total run time: " << time_span.count() << "s" << std::endl;
    return 0;
}
