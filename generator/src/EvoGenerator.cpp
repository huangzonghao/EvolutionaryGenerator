#include "EvoGenerator.h"

#include <chrono>
#include <fstream>
#include <iostream>
#include <filesystem>

#include <sferes/gen/evo_float.hpp>
#include <sferes/modif/dummy.hpp>
#include "sferes_fit_EvoGenFitness.hpp"
#include "sferes_phen_EvoGenPhen.hpp"
#include "sferes_eval_EvoGenEval.hpp"
#include "sferes_stat_EvoGenStat.hpp"
#include "sferes_qd_container_grid.hpp"
#include "sferes_qd_selector_uniform.hpp"
#include "sferes_qd_EvoGenQD.hpp"
#include "sferes_params.h"

typedef sferes::phen::EvoGenPhen<sferes::gen::EvoFloat<Params::evo_float::dimension, Params>,
                                 sferes::fit::EvoGenFitness<Params>,
                                 Params> phen_t;
typedef sferes::qd::EvoGenQD<phen_t,
                             sferes::eval::EvoGenEval<Params>,
                             boost::fusion::vector<sferes::stat::EvoGenStat<phen_t, Params> >,
                             sferes::modif::Dummy<>,
                             sferes::qd::selector::Uniform<phen_t>,
                             sferes::qd::container::Grid<phen_t> > qd_t;

void EvoGenerator::run() {
    // TODO: test if evo_params_/sim_params_ set and res_dir_ exists

    qd_t qd(evo_params_);
    qd.set_res_dir(res_dir_);
    qd.eval().set_sim_params(sim_params_);
    sim_params_.Save(res_dir_ + "/sim_params.xml");

    std::chrono::duration<double> time_span; // in seconds
    std::chrono::steady_clock::time_point tik = std::chrono::steady_clock::now();
    qd.run("EvolutionGenerator");
    time_span = std::chrono::steady_clock::now() - tik;

    std::ofstream ofs;
    ofs.open(res_dir_ + "/progress.txt", std::ofstream::out | std::ofstream::app);
    ofs << "Finished in: " << time_span.count() << "s" << std::endl;
    ofs.close();

    std::cout << "Generation done" << std::endl
              << "Total run time: " << time_span.count() << "s" << std::endl;

}

// filename should be the path to a valid archive dump file
void EvoGenerator::resume(const std::string& filename) {
    qd_t qd;
    SimulatorParams sim_params;
    std::filesystem::path res_path(filename);
    sim_params.Load(res_path.parent_path().parent_path().string() + "/sim_params.xml");
    qd.eval().set_sim_params(sim_params);
    qd.resume(filename);
}
