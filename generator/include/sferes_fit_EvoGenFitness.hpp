#ifndef SFERES_FIT_EVOGENFITNESS_HPP_6UG4LCXA
#define SFERES_FIT_EVOGENFITNESS_HPP_6UG4LCXA

#include <sferes/fit/fit_qd.hpp>

#include "GenerateDemoRobot.h"
#include "SimulationManager.h"

std::vector<float> fitness_vec;
std::vector<std::vector<float> > genome_vec;

FIT_QD(EvoGenFitness) {
public:

    // this method is used in the stat::State::show()
    // currently setting up a place holder here
    template <typename Indiv> void eval(Indiv& ind) {
        SimulationManager sm;
        eval(ind, sm);
    }

    template <typename Indiv>
    void eval(Indiv& ind, SimulationManager& sm) {

        sm.LoadUrdfString(generate_demo_robot_string("leg", ind.data()));
        sm.RunSimulation();

        this->_value = sm.GetRootBodyDisplacementX();

        fitness_vec.push_back(this->_value);
        genome_vec.push_back(ind.data());

        std::vector<double> feature = {ind.gen().data(0), ind.gen().data(3)};
        this->set_desc(feature);

        // if (this->mode() == sferes::fit::mode::view) {
            // std::ofstream ofs("fit.dat");
            // ofs << "Reading log file " << "fit.dat" << "!" << std::endl;
        // }
    }
};

#endif /* end of include guard: SFERES_FIT_EVOGENFITNESS_HPP_6UG4LCXA */

