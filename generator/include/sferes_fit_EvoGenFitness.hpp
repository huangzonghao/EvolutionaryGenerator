#ifndef SFERES_FIT_EVOGENFITNESS_HPP_6UG4LCXA
#define SFERES_FIT_EVOGENFITNESS_HPP_6UG4LCXA

#include <sferes/fit/fitness.hpp>

#include "GenerateDemoRobot.h"
#include "SimulationManager.h"

namespace sferes {
namespace fit {

SFERES_FITNESS(EvoGenFitness, sferes::fit::Fitness) {
  public:
    EvoGenFitness()
        : _dead(false), _desc(2), _novelty(-std::numeric_limits<double>::infinity()),
        _curiosity(0), _lq(0) {}

    const std::vector<double>& desc() const { return _desc; }
    double novelty() const { return _novelty; }
    void set_novelty(double nov) { _novelty = nov; }
    double curiosity() const { return _curiosity; }
    void set_curiosity(double cur) { _curiosity = cur; }
    double local_quality() const { return _lq; }
    void set_local_quality(double lq) { _lq = lq; }
    bool dead() const { return _dead; }
    void set_value(float val) { this->_value = val; }

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

        update_desc(ind);
    }

    template <typename Indiv>
    void update_desc(Indiv& ind) {
        _desc[0] = ind.gen().data(0);
        _desc[1] = ind.gen().data(3);
    }

    protected:
        bool _dead;
        std::vector<double> _desc;
        double _novelty;
        double _curiosity;
        double _lq;
};

} // namespace fit
} // namespace sferes

#endif /* end of include guard: SFERES_FIT_EVOGENFITNESS_HPP_6UG4LCXA */

