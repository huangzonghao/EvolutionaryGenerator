#include <iostream>
#include <fstream>

#include <sferes/gen/evo_float.hpp>
#include <sferes/modif/dummy.hpp>
#include <sferes/phen/parameters.hpp>
#include <sferes/run.hpp>
#include <sferes/stat/best_fit.hpp>
#include <sferes/stat/qd_container.hpp>
#include <sferes/stat/qd_selection.hpp>
#include <sferes/stat/qd_progress.hpp>

#include <sferes/fit/fit_qd.hpp>
#include <sferes/qd/container/archive.hpp>
#include <sferes/qd/container/grid.hpp>
#include <sferes/qd/quality_diversity.hpp>
#include <sferes/qd/selector/uniform.hpp>

#include "sferes_eval_EvoGenEval.hpp"
#include "sferes_fit_EvoGenFitness.hpp"

#include "evo_paths.h"

#include "sferes_params.h"

int main(int argc, char **argv)
{
    using namespace sferes;

    typedef EvoGenFitness<Params> fit_t;
    typedef gen::EvoFloat<Params::evo_float::dimension, Params> gen_t;

    typedef phen::Parameters<gen_t, fit_t, Params> phen_t;

    typedef eval::EvoGenEval<Params> eval_t;
    // typedef eval::Parallel<Params> eval_t;

    typedef boost::fusion::vector<sferes::stat::BestFit<phen_t, Params>,
                                  sferes::stat::QdContainer<phen_t, Params>,
                                  sferes::stat::QdProgress<phen_t, Params> > stat_t;

    typedef modif::Dummy<> modifier_t;

    typedef qd::MapElites<phen_t, eval_t, stat_t, modifier_t, Params> qd_t;

    qd_t qd;
    run_ea(argc, argv, qd);
    std::cout << "Generation done" << std::endl;
    std::cout << "Fitness:" << std::endl;

    // output the data
    time_t t = time(0);   // get time now
    struct tm * now = localtime( & t  );

    char time_buffer [80];
    strftime(time_buffer, 80, "%Y%m%d%H%M%S", now);

    std::ofstream data_file;

    data_file.open (Result_Output_Dir + "/Result_" +
                    "P" + std::to_string(Params::pop::size) +
                    "G" + std::to_string(Params::pop::nb_gen) + "_" +
                    std::to_string(Params::qd::grid_shape(0)) + "x" + std::to_string(Params::qd::grid_shape(1)) +
                    "_" + time_buffer + ".csv");

    for(int i = 0; i < fitness_vec.size(); ++i){
        data_file << i + 1 << "," << fitness_vec[i];
        for(int j = 0; j < genome_vec[i].size(); ++j){
            data_file << "," << genome_vec[i][j];
        }
        data_file << std::endl;
    }

    data_file.close();

    std::cout << "best fitness:" << qd.stat<0>().best()->fit().value() << std::endl;
    std::cout << "archive size:" << qd.stat<1>().archive().size() << std::endl;
    return 0;
}
