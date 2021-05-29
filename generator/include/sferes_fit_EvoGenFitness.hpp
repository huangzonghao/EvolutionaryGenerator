#ifndef SFERES_FIT_EVOGENFITNESS_HPP_6UG4LCXA
#define SFERES_FIT_EVOGENFITNESS_HPP_6UG4LCXA

#include <boost/serialization/nvp.hpp>
#include <boost/serialization/vector.hpp>

#include "GenerateDemoRobot.h"
#include "SimulationManager.h"

namespace sferes {
namespace fit {

class EvoGenFitness {
  public:
    const std::vector<double>& desc() const { return _desc; }
    double novelty() const { return _novelty; }
    void set_novelty(double nov) { _novelty = nov; }
    double curiosity() const { return _curiosity; }
    void set_curiosity(double cur) { _curiosity = cur; }
    double local_quality() const { return _lq; }
    void set_local_quality(double lq) { _lq = lq; }
    bool dead() const { return _dead; }
    double value() const { return _value; }
    void set_value(double val) { _value = val; }

    template <typename Indiv>
    void eval(Indiv& ind, SimulationManager& sm) {

        sm.RemoveAllMotors();
        int num_links;
        int num_legs = ind.data(3);
        int cursor = 5;
        // the leg order in Phen is: FL FR ML MR BL BR
        // the leg order in Sim Controller is: FL ML BL BR MR FR
        // so the conversion happens here
        for (int i = 0; i < num_legs / 2; ++i) {
            num_links = ind.data(cursor);
            sm.AddEvoGenMotor("chassis_leg_" + std::to_string(2 * i) + "-0", i, 0);
            for (int j = 1; j < num_links; ++j) {
                sm.AddEvoGenMotor("leg_" + std::to_string(2 * i) + "-" + std::to_string(j - 1) +
                                  "_leg_" + std::to_string(2 * i) + "-" + std::to_string(j), i, j);
            }
            cursor += num_links * 2 + 2; // offsets include leg_pos and num_links

            // the mirrored leg
            num_links = ind.data(cursor);
            sm.AddEvoGenMotor("chassis_leg_" + std::to_string(2 * i + 1) + "-0", num_legs - 1 - i, 0);
            for (int j = 1; j < num_links; ++j) {
                sm.AddEvoGenMotor("leg_" + std::to_string(2 * i + 1) + "-" + std::to_string(j - 1) +
                                  "_leg_" + std::to_string(2 * i + 1) + "-" + std::to_string(j), num_legs - 1 - i, j);
            }
            cursor += num_links * 2 + 2; // offsets include leg_pos and num_links
        }

        sm.LoadUrdfString(generate_demo_robot_string("leg", ind.data()));
        sm.RunSimulation();

        _value = sm.GetRootBodyDisplacementX();

        update_desc(ind);
    }

    template <typename Indiv>
    void update_desc(Indiv& ind) {
        // Note: descriptor needs to be in range [0, 1]
        _desc[0] = ind.gen().data(0);
        _desc[1] = ind.gen().size() - 10; // lengeth of gen [10, 25]
        // TODO: better handling the map size
        _desc[1] = _desc[1] / 20;
    }

    template<class Archive>
    void serialize(Archive & ar, const unsigned int version) {
        ar & BOOST_SERIALIZATION_NVP(_value);
        ar & BOOST_SERIALIZATION_NVP(_desc);
    }

  protected:
    bool _dead = false;
    std::vector<double> _desc = {0.0, 0.0};
    double _novelty = -std::numeric_limits<double>::infinity();
    double _curiosity = 0;
    double _lq = 0;
    double _value = 0;
};

} // namespace fit
} // namespace sferes

#endif /* end of include guard: SFERES_FIT_EVOGENFITNESS_HPP_6UG4LCXA */

