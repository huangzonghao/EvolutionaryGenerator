#ifndef EVOGEN_GENERATOR_SFERES_FIT_URDFFITNESS_HPP_
#define EVOGEN_GENERATOR_SFERES_FIT_URDFFITNESS_HPP_

#include <boost/serialization/nvp.hpp>
#include <boost/serialization/vector.hpp>

#include "RobotRepresentation.h"
#include "SimulationManager.h"

namespace sferes {
namespace fit {

// TODO: the dimension of archive map here is hard coded.
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
            write_desc(-2);
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
            write_desc(-3);
            _dead = true;
            return;
        }

        // reward x movement and penalize y movement
        _value = sm.GetRootBodyDisplacementX() - 0.5 * std::abs(sm.GetRootBodyDisplacementY());
        // _value = sm.GetRootBodyDisplacementX() - 0.5 * std::abs(sm.GetRootBodyAccumulatedY());

        // Update Descriptors
        // Note: descriptor needs to be in range [0, 1]

        // Feature 0 -- Body Length
        _desc[0] = range_to_unit(robot.get_body_length(), 0.5, 2.3);

        // Feature 1 -- Leg Length SD
        double max_leg_length = 0;
        double avg_leg_length = 0;
        double tmp_leg_length = 0;
        for (int i = 0; i < num_legs; ++i) {
            tmp_leg_length = robot.legs[i].length();
            avg_leg_length += tmp_leg_length;
            if (tmp_leg_length > max_leg_length)
                max_leg_length = tmp_leg_length;
        }

        avg_leg_length /= num_legs;
        double sd = 0;
        for (int i = 0; i < num_legs; ++i) {
            sd += std::pow(robot.legs[i].length() - avg_leg_length, 2);
        }
        sd = std::sqrt(sd / num_legs);
        _desc[1] = range_to_unit(sd, 0, 1); // assuming range [0, 1];

        // Feature 2 -- Average Leg Length
        // Longest link 1, shortest link 0.2 --> Longest leg 4.5, shortest leg 0.2
        // Now chose 4 as the maximum, as 4.5 was rarely reached.
        _desc[2] = range_to_unit(avg_leg_length, 0.2, 4);

        // // Feature 3 -- Max Leg Length
        // _desc[3] = range_to_unit(max_leg_length, 0.2, 4.5);

        // Feature 3 -- Total Num of Links
        int total_num_links = 0;
        for (int i = 0; i < num_legs; ++i) {
            total_num_links += robot.legs[i].num_links;
        }
        // minimum 2 legs with 2 links per leg; maximum 6 legs with 3 links per leg
        _desc[3] = range_to_unit(total_num_links, 4, 18);

        // regulate descriptor
        for (auto& e : _desc)
            e = std::clamp(e, 0.0, 1.0);
    }
    static constexpr const char* descriptor_names[4] = {"Body Length", "Leg Length SD",
                                                        "Avg Leg Length", "Total Num of Links"};

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
    std::vector<double> _desc = {-1.0, -1.0, -1.0, -1.0};
    double _novelty = -std::numeric_limits<double>::infinity();
    double _curiosity = 0;
    double _lq = 0;
    double _value = 0;

    // scale the value within the given range to [0, 1]
    inline double range_to_unit(double raw, double min, double max) {
        return (raw - min) / (max - min);
    }

  private:
    // Set flag in descriptors.
    void write_desc(double value) {
        for (int i = 0; i < _desc.size(); ++i)
            _desc[i] = value;
    }
};

} // namespace fit
} // namespace sferes

#endif /* end of include guard: EVOGEN_GENERATOR_SFERES_FIT_URDFFITNESS_HPP_ */
