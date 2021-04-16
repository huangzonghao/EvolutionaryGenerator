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

#include "GenerateDemoRobot.h"
#include "SimulationManager.h"
#include "evo_paths.h"

using namespace sferes::gen::evo_float;

std::vector<double> fitness_vec;
std::vector<std::vector<double> > genome_vec;

struct Params {
    struct evo_float {
        // Mutation
        // polynomial, gaussian, uniform
        SFERES_CONST mutation_t mutation_type = polynomial;
        SFERES_CONST float mutation_rate = 0.1f;
        SFERES_CONST float eta_m = 10.0f;

        // Crossover
        // sbx, recombination
        SFERES_CONST cross_over_t cross_over_type = sbx;
        SFERES_CONST float cross_rate = 0.75f;
        SFERES_CONST float eta_c = 10.0f;
    };

    struct pop {
        // number of initial random points
        SFERES_CONST size_t init_size = 10;
        // number of initial seeds = initial_aleat * size
        SFERES_CONST size_t initial_aleat = 1;
        SFERES_CONST size_t size = 10;
        SFERES_CONST size_t nb_gen = 2;
        // number of generations to take archive
        SFERES_CONST size_t dump_period = 1;
    };

    struct parameters {
        SFERES_CONST float min = 0.5;
        SFERES_CONST float max = 1.5;
    };

    struct nov {
        SFERES_CONST size_t deep = 2;
        SFERES_CONST double l = 1;
        SFERES_CONST double k = 8;
        SFERES_CONST double eps = 0.01;
    };

    struct qd {
        SFERES_CONST size_t behav_dim = 1;
        SFERES_ARRAY(size_t, grid_shape, 4);
    };
};

// Evaluate the robot and generate the fitness
FIT_QD(RobotFitness) {
public:

    // this method is used in the stat::State::show()
    // currently setting up a place holder here
    template <typename Indiv> void eval(Indiv& ind) {
        SimulationManager sm;
        eval(ind, sm);
    }

    template <typename Indiv>
    void eval(Indiv& ind, SimulationManager& sm) {

        double scales[7];
        std::vector<double> tmp_vector;
        for(int i = 0; i < 7; ++i) {
            scales[i] = ind.data(i);
            tmp_vector.push_back(ind.data(i));
        }

        sm.LoadUrdfString(generate_demo_robot_string("leg", scales));
        sm.RunSimulation();

        this->_value = sm.GetRootBodyDisplacementX();

        fitness_vec.push_back(this->_value);
        genome_vec.push_back(tmp_vector);

        // std::vector<double> data = { ind.gen().data(0), ind.gen().data(1) };
        // this->set_desc(data);

        // if (this->mode() == sferes::fit::mode::view) {
            // std::ofstream ofs("fit.dat");
            // ofs << "Reading log file " << "fit.dat" << "!" << std::endl;
        // }
    }
};

int main(int argc, char **argv)
{
    using namespace sferes;

    typedef RobotFitness<Params> fit_t;
    typedef gen::EvoFloat<20, Params> gen_t;

    //std::cout << "Gen: " << gen_t.data << std::endl;
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
    for(int i = 0; i < fitness_vec.size(); ++i){
        std::cout << i + 1 << ", " << fitness_vec[i];
        std::cout << ", Design vector: ";
        for(int j = 0; j < genome_vec[i].size(); ++j){
            std::cout << genome_vec[i][j] << " ";
        }
        std::cout << std::endl;
    }

    // output the data
    time_t t = time(0);   // get time now
    struct tm * now = localtime( & t  );

    char time_buffer [80];
    strftime(time_buffer, 80, "%Y%m%d%H%M%S", now);

    std::ofstream data_file;

    data_file.open (Result_Output_Dir + "/Result_" +
                    "P" + std::to_string(Params::pop::size) +
                    "G" + std::to_string(Params::pop::nb_gen) +
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
