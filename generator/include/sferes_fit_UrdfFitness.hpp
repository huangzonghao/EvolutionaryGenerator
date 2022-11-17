#ifndef EVOGEN_GENERATOR_SFERES_FIT_URDFFITNESS_HPP_
#define EVOGEN_GENERATOR_SFERES_FIT_URDFFITNESS_HPP_

#include <boost/serialization/nvp.hpp>
#include <boost/serialization/vector.hpp>

#include "sferes_phen_EvoGenPhen.hpp"
#include "RobotRepresentation.h"
#include "SimulationManager.h"

namespace sferes {
namespace fit {

// TODO: decouple fitness and descriptors
class Evaluator {
  public:
    virtual void operator()(sferes::phen::EvoGenPhen& ind, SimulationManager& sm) const = 0;
    virtual const char *const * get_descriptor_names() = 0;

  protected:
    bool eval(sferes::phen::EvoGenPhen& ind, SimulationManager& sm) const {
        if (!ind.valid()) {
            ind.fit().write_desc(-2);
            return false;
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
            ind.fit().write_desc(-3);
            return false;
        }
    }

    // scale the value within the given range to [0, 1]
    inline double range_to_unit(double raw, double min, double max) const {
        return (raw - min) / (max - min);
    }
};

class Eva_2D_v1_Fit_v1 : public Evaluator {
  public:
    void operator()(sferes::phen::EvoGenPhen& ind, SimulationManager& sm) const override {
        if (!eval(ind, sm)) {
            ind.fit().dead = true;
            return;
        }

        auto& fit = ind.fit();
        const auto& robot = ind.get_robot();

        // Fitness
        // reward x movement and penalize y movement
        fit.value = sm.GetRootBodyDisplacementX() - 0.5 * std::abs(sm.GetRootBodyDisplacementY());

        // Descriptors
        // Note: descriptor needs to be in range [0, 1]

        // Feature 0 -- Body Length
        fit.desc[0] = range_to_unit(robot.get_body_length(), 0.5, 2.3);

        // Feature 1 -- Leg Length SD
        int num_legs = robot.num_legs();
        double avg_leg_length = 0;
        double tmp_leg_length = 0;
        for (int i = 0; i < num_legs; ++i) {
            tmp_leg_length = robot.legs[i].length();
            avg_leg_length += tmp_leg_length;
        }

        avg_leg_length /= num_legs;
        double sd = 0;
        for (int i = 0; i < num_legs; ++i) {
            sd += std::pow(robot.legs[i].length() - avg_leg_length, 2);
        }
        sd = std::sqrt(sd / num_legs);
        fit.desc[1] = range_to_unit(sd, 0, 1); // assuming range [0, 1];

        // regulate descriptor
        fit.clamp_desc();
    }
    const char *const * get_descriptor_names() override { return descriptor_names; }
    static constexpr const char* descriptor_names[] = {"Body Length", "Leg Length SD"};
};

class Eva_2D_v1_Fit_v2 : public Evaluator {
  public:
    void operator()(sferes::phen::EvoGenPhen& ind, SimulationManager& sm) const override {
        if (!eval(ind, sm)) {
            ind.fit().dead = true;
            return;
        }

        auto& fit = ind.fit();
        const auto& robot = ind.get_robot();

        // penalize absolute y movement
        fit.value = sm.GetRootBodyDisplacementX() - 0.5 * std::abs(sm.GetRootBodyAccumulatedY());

        // Feature 0 -- Body Length
        fit.desc[0] = range_to_unit(robot.get_body_length(), 0.5, 2.3);

        // Feature 1 -- Leg Length SD
        int num_legs = robot.num_legs();
        double avg_leg_length = 0;
        double tmp_leg_length = 0;
        for (int i = 0; i < num_legs; ++i) {
            tmp_leg_length = robot.legs[i].length();
            avg_leg_length += tmp_leg_length;
        }

        avg_leg_length /= num_legs;
        double sd = 0;
        for (int i = 0; i < num_legs; ++i) {
            sd += std::pow(robot.legs[i].length() - avg_leg_length, 2);
        }
        sd = std::sqrt(sd / num_legs);
        fit.desc[1] = range_to_unit(sd, 0, 1); // assuming range [0, 1];

        // regulate descriptor
        fit.clamp_desc();
    }
    const char *const * get_descriptor_names() override { return descriptor_names; }
    static constexpr const char* descriptor_names[] = {"Body Length", "Leg Length SD"};
};

class Eva_4D_v1_Fit_v1 : public Evaluator {
  public:
    void operator()(sferes::phen::EvoGenPhen& ind, SimulationManager& sm) const override {
        if (!eval(ind, sm)) {
            ind.fit().dead = true;
            return;
        }

        auto& fit = ind.fit();
        const auto& robot = ind.get_robot();

        // reward x movement and penalize y movement
        fit.value = sm.GetRootBodyDisplacementX() - 0.5 * std::abs(sm.GetRootBodyDisplacementY());

        // Feature 0 -- Body Length
        fit.desc[0] = range_to_unit(robot.get_body_length(), 0.5, 2.3);

        // Feature 1 -- Leg Length SD
        int num_legs = robot.num_legs();
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
        fit.desc[1] = range_to_unit(sd, 0, 1); // assuming range [0, 1];

        // Feature 2 -- Average Leg Length
        // Longest link 1, shortest link 0.2 --> Longest leg 4.5, shortest leg 0.2
        // Now chose 4 as the maximum, as 4.5 was rarely reached.
        fit.desc[2] = range_to_unit(avg_leg_length, 0.2, 4);

        // // Feature 3 -- Max Leg Length
        fit.desc[3] = range_to_unit(max_leg_length, 0.2, 4.5);

        // regulate descriptor
        fit.clamp_desc();
    }
    const char *const * get_descriptor_names() override { return descriptor_names; }
    static constexpr const char* descriptor_names[] = {"Body Length",    "Leg Length SD",
                                                       "Avg Leg Length", "Max Leg Length"};
};

class Eva_4D_v2_Fit_v1 : public Evaluator {
  public:
    void operator()(sferes::phen::EvoGenPhen& ind, SimulationManager& sm) const override {
        if (!eval(ind, sm)) {
            ind.fit().dead = true;
            return;
        }

        auto& fit = ind.fit();
        const auto& robot = ind.get_robot();

        // reward x movement and penalize y movement
        fit.value = sm.GetRootBodyDisplacementX() - 0.5 * std::abs(sm.GetRootBodyDisplacementY());

        // Feature 0 -- Body Length
        fit.desc[0] = range_to_unit(robot.get_body_length(), 0.5, 2.3);

        // Feature 1 -- Leg Length SD
        int num_legs = robot.num_legs();
        double avg_leg_length = 0;
        double tmp_leg_length = 0;
        for (int i = 0; i < num_legs; ++i) {
            tmp_leg_length = robot.legs[i].length();
            avg_leg_length += tmp_leg_length;
        }

        avg_leg_length /= num_legs;
        double sd = 0;
        for (int i = 0; i < num_legs; ++i) {
            sd += std::pow(robot.legs[i].length() - avg_leg_length, 2);
        }
        sd = std::sqrt(sd / num_legs);
        fit.desc[1] = range_to_unit(sd, 0, 1); // assuming range [0, 1];

        // Feature 2 -- Average Leg Length
        // Longest link 1, shortest link 0.2 --> Longest leg 4.5, shortest leg 0.2
        // Now chose 4 as the maximum, as 4.5 was rarely reached.
        fit.desc[2] = range_to_unit(avg_leg_length, 0.2, 4);

        // Feature 3 -- Total Num of Links
        int total_num_links = 0;
        for (int i = 0; i < num_legs; ++i) {
            total_num_links += robot.legs[i].num_links;
        }
        // minimum 2 legs with 2 links per leg; maximum 6 legs with 3 links per leg
        fit.desc[3] = range_to_unit(total_num_links, 4, 18);

        // regulate descriptor
        fit.clamp_desc();
    }
    const char *const * get_descriptor_names() override { return descriptor_names; }
    static constexpr const char* descriptor_names[] = {"Body Length",    "Leg Length SD",
                                                       "Avg Leg Length", "Total Num of Links"};
};

static std::shared_ptr<Evaluator> get_evaluator(const std::string& str_name) {
    if      (str_name == "2d_v1_fit_v1") return std::make_shared<Eva_2D_v1_Fit_v1>();
    else if (str_name == "2d_v1_fit_v2") return std::make_shared<Eva_2D_v1_Fit_v2>();
    else if (str_name == "4d_v1_fit_v1") return std::make_shared<Eva_4D_v1_Fit_v1>();
    else if (str_name == "4d_v2_fit_v1") return std::make_shared<Eva_4D_v2_Fit_v1>();
    else {
        std::cout << "Error: undefined evaluator name " << str_name << std::endl;
        exit(1);
    }
}


} // namespace fit
} // namespace sferes

#endif /* end of include guard: EVOGEN_GENERATOR_SFERES_FIT_URDFFITNESS_HPP_ */
