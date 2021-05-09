#ifndef SFERES_FIT_EVOGENFITNESS_HPP_6UG4LCXA
#define SFERES_FIT_EVOGENFITNESS_HPP_6UG4LCXA

#include <sferes/fit/fit_qd.hpp>

#include "GenerateDemoRobot.h"
#include "SimulationManager.h"

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

        // for some reason Phen uses float as data type
        auto design_vector = std::vector<double>(ind.data().begin(), ind.data().end());

        // TODO: dirty hack here
        if (design_vector[0] > 1)
            design_vector[0] = 6;
        else
            design_vector[0] = 4;

        sm.RemoveAllMotors();
        for (int i = 0; i < design_vector[0]; ++i)
            sm.AddMotor("MOTOR", "chassis", "chassis_leg_" + std::to_string(i), 1,0.1,0.1,0.1);

        sm.LoadUrdfString(generate_demo_robot_string("leg", design_vector));
        sm.RunSimulation();

        this->_value = sm.GetRootBodyDisplacementX();

        std::vector<double> feature = {ind.gen().data(0), ind.gen().data(3)};
        this->set_desc(feature);
    }

    template <typename Indiv>
    void update_desc(Indiv& ind) {
        std::vector<double> feature = {ind.gen().data(0), ind.gen().data(3)};
        this->set_desc(feature);
    }
};

#endif /* end of include guard: SFERES_FIT_EVOGENFITNESS_HPP_6UG4LCXA */

