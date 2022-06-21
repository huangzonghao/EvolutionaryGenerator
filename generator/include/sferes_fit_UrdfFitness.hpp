#ifndef EVOGEN_GENERATOR_SFERES_FIT_URDFFITNESS_HPP_
#define EVOGEN_GENERATOR_SFERES_FIT_URDFFITNESS_HPP_

#include <boost/serialization/nvp.hpp>
#include <boost/serialization/vector.hpp>

#include "RobotRepresentation.h"
#include "SimulationManager.h"

namespace sferes {
namespace fit {

class UrdfFitness {
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

    // TODO: all the fitness object belong to some phen. they should be able
    // to evaluate themselves without asking for ind again
    template <typename Indiv>
    void eval(Indiv& ind, SimulationManager& sm) {
        if (!ind.valid()) {
            _desc[0] = -2;
            _desc[1] = -2;
            _dead = true;
            return;
        }

        const auto& robot = ind.get_robot();
        sm.RemoveAllMotors();
        int num_legs = robot.num_legs();
        // the leg order in Phen is: FL ML BL BR MR FR, which is the same as
        // the leg order in Sim Controller is: FL ML BL BR MR FR
        for (int i = 0; i < num_legs; ++i) {
            sm.AddEvoGenMotor("chassis_leg_" + std::to_string(i) + "-0", i, 0);
            for (int j = 1; j < robot.legs[i].num_links; ++j) {
                sm.AddEvoGenMotor("leg_" + std::to_string(i) + "-" + std::to_string(j - 1) +
                                  "_leg_" + std::to_string(i) + "-" + std::to_string(j), i, j);
            }
        }

        sm.LoadUrdfString(robot.get_urdf_string());
        sm.RunSimulation();
        if (sm.CheckRobotSelfCollision() == true) {
            _desc[0] = -3;
            _desc[1] = -3;
            _dead = true;
            return;
        }

        // reward x movement and penalize y movement
        // _value = sm.GetRootBodyDisplacementX() - 0.5 * std::abs(sm.GetRootBodyDisplacementY());
        _value = sm.GetRootBodyDisplacementX() - 0.5 * std::abs(sm.GetRootBodyAccumulatedY());

        // TODO: this part needs to be updated
        // Update Descriptors
        // Note: descriptor needs to be in range [0, 1]
        // double body_length = robot.get_body_length();
        // _desc[0] = robot.get_body_size(1) / body_length;
        // _desc[0] /=  2; // assuming the range of the origin ratio is [0, 2], ignoring the rest
        // _desc[0] = ind.data(1);
        _desc[0] = range_to_unit(robot.get_body_length(), 0.5, 2.3);
        double avg_leg_length = 0;
        for (int i = 0; i < num_legs; ++i) {
            avg_leg_length += robot.legs[i].length();
        }

        avg_leg_length /= num_legs;
        double sd = 0;
        for (int i = 0; i < num_legs; ++i) {
            sd += std::pow(robot.legs[i].length() - avg_leg_length, 2);
        }
        sd = std::sqrt(sd / num_legs);

        // _desc[1] = avg_leg_length / body_length;
        // _desc[1] /= 8; // assuming range [0, 8];
        _desc[1] = range_to_unit(sd, 0, 1); // assuming range [0, 1];

        // regulate descriptor
        for (auto& e : _desc)
            e = std::clamp(e, 0.0, 1.0);
    }
    static constexpr const char* descriptor_name[2] = {"body length", "leg length sd"};

    template<class Archive>
    void serialize(Archive & ar, const unsigned int version) {
        ar & BOOST_SERIALIZATION_NVP(_value);
        ar & BOOST_SERIALIZATION_NVP(_desc);
    }

  protected:
    // A robot is dead if:
    //     * Gene is invalid (too short)
    //     * Self-collided at initial pose
    bool _dead = false;
    std::vector<double> _desc = {-1.0, -1.0};
    double _novelty = -std::numeric_limits<double>::infinity();
    double _curiosity = 0;
    double _lq = 0;
    double _value = 0;

    // scale the value within the given range to [0, 1]
    inline double range_to_unit(double raw, double min, double max) {
        return (raw - min) / (max - min);
    }
};

} // namespace fit
} // namespace sferes

#endif /* end of include guard: EVOGEN_GENERATOR_SFERES_FIT_URDFFITNESS_HPP_ */
