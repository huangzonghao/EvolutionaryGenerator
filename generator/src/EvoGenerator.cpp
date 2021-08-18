#include "EvoGenerator.h"

#include <chrono>
#include <fstream>
#include <iostream>
#include <filesystem>

#include "sferes_fit_UrdfFitness.hpp"
#include "sferes_fit_RobogamiFitness.hpp"
#include "sferes_gen_EvoGenFloat.hpp"
#include "sferes_phen_EvoGenPhen.hpp"
#include "sferes_eval_EvoGenEval.hpp"
#include "sferes_stat_EvoGenStat.hpp"
#include "sferes_qd_container_grid.hpp"
#include "sferes_qd_selector_uniform.hpp"
#include "sferes_qd_EvoGenQD.hpp"

typedef sferes::fit::UrdfFitness fit_t;
// typedef sferes::fit::RobogamiFitness fit_t;
typedef sferes::phen::EvoGenPhen<sferes::gen::EvoGenFloat, fit_t> phen_t;
typedef sferes::qd::EvoGenQD<phen_t,
                             sferes::eval::EvoGenEval,
                             boost::fusion::vector<sferes::stat::EvoGenStat>,
                             sferes::qd::selector::Uniform<phen_t>,
                             sferes::qd::container::Grid<phen_t>> qd_t;

void EvoGenerator::run() {
    if (!evo_params_.output_enabled())
        std::cout << "Note: Output disabled" << std::endl;
    evo_params_.feature_description().emplace_back(fit_t::descriptor_name[0]);
    evo_params_.feature_description().emplace_back(fit_t::descriptor_name[1]);
    qd_t qd(evo_params_, sim_params_);
    qd.set_res_dir(res_dir_);

    std::chrono::duration<double> time_span; // in seconds
    std::chrono::steady_clock::time_point tik = std::chrono::steady_clock::now();
    qd.run("EvolutionGenerator");
    time_span = std::chrono::steady_clock::now() - tik;

    if (evo_params_.output_enabled()) {
        std::ofstream ofs;
        ofs.open(res_dir_ + "/progress.txt", std::ofstream::out | std::ofstream::app);
        ofs << "Finished in: " << time_span.count() << "s" << std::endl;
        ofs.close();
    }

    std::cout << "Generation done" << std::endl
              << "Total run time: " << time_span.count() << "s" << std::endl;

}

// filename should be the path to a valid archive dump file
void EvoGenerator::resume(const std::string& res_dir, int dump_gen_id) {
    qd_t qd;
    qd.resume(res_dir, dump_gen_id);
}
