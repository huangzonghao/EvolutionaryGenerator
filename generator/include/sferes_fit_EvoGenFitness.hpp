#ifndef SFERES_FIT_EVOGENFITNESS_HPP_6UG4LCXA
#define SFERES_FIT_EVOGENFITNESS_HPP_6UG4LCXA

#include <sferes/fit/fit_qd.hpp>

#include "GenerateDemoRobot.h"
#include "SimulationManager.h"

namespace sferes {
namespace fit {

FIT_QD(EvoGenFitness) {
  public:
    template <typename Indiv>
    void eval(Indiv& ind, SimulationManager& sm) {

        auto design_vector = ind.data();

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

} // namespace fit
} // namespace sferes

#endif /* end of include guard: SFERES_FIT_EVOGENFITNESS_HPP_6UG4LCXA */

