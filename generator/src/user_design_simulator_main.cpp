#include <chrono>
#include <thread>
#include <iostream>
#include <fstream>
#include <sstream>
#include <filesystem>

#include "SimulatorParams.h"
#include "SimulationManager.h"
#include "RobotRepresentation.h"
#include "sferes_gen_EvoGenFloat.hpp"
#include "sferes_fit_UrdfFitness.hpp"
#include "sferes_phen_EvoGenPhen.hpp"

#include "evo_paths.h"

typedef sferes::fit::UrdfFitness fit_t;
typedef sferes::phen::EvoGenPhen<sferes::gen::EvoGenFloat, fit_t> phen_t;

void debug_pause() {
    // do {
        // std::cout << std::endl;
    // } while (!std::cin.get());
    std::this_thread::sleep_for(std::chrono::seconds(5));
}

int main(int argc, char **argv) {
    if (argc < 2) {
        std::cout << "User_Design_Simulator: Not enough input. Launch this program from browser" << std::endl
                  << "    Input format: <environment>, <gene>" << std::endl;
        return 1;
    }

    std::string tmp_str;
    std::string env;
    std::vector<double> gene;
    std::stringstream input_ss(argv[1]);
    if (input_ss.good()) {
        std::getline(input_ss, tmp_str, ':'); // first remove the protocol scheme
        std::getline(input_ss, env, ','); // read in environment
    }
    while(input_ss.good()) {
        std::getline(input_ss, tmp_str, ',');
        gene.push_back(std::stod(tmp_str));
    }

    mesh_info.set_mesh_dir(Robot_Parts_Dir);
    mesh_info.init();

    EvoParams evo_params;
    evo_params.Load(EvoGen_Params_Dir + "/evo_params.xml");
    phen_t phen(gene, evo_params.phen_data_min(), evo_params.phen_data_max());
    phen.develop();
    const auto& robot = phen.get_robot();

    SimulatorParams sim_params;
    sim_params.Load(EvoGen_Params_Dir + "/sim_params.xml");
    sim_params.env_dir = EvoGen_Maps_Dir;
    sim_params.SetEnv(env);

    SimulationManager sm;
    sm.SetTimeout(sim_params.time_out);
    sm.SetCamera(sim_params.camera_pos[0],
                 sim_params.camera_pos[1],
                 sim_params.camera_pos[2],
                 sim_params.camera_pos[3],
                 sim_params.camera_pos[4],
                 sim_params.camera_pos[5]);
    for (auto& wp : sim_params.GetWaypoints())
        sm.AddWaypoint(wp[0], wp[1], wp[2]);

    sm.SetEnv(sim_params.GetEnv(),
              sim_params.env_dim[0],
              sim_params.env_dim[1],
              sim_params.env_dim[2]);
    sm.SetEnvRot(sim_params.env_rot[0],
                 sim_params.env_rot[1],
                 sim_params.env_rot[2],
                 sim_params.env_rot[3]);

    for (int i = 0; i < robot.num_legs(); ++i) {
        sm.AddEvoGenMotor("chassis_leg_" + std::to_string(i) + "-0", i, 0);
        for (int j = 1; j < robot.legs[i].num_links; ++j) {
            sm.AddEvoGenMotor("leg_" + std::to_string(i) + "-" + std::to_string(j - 1) +
                              "_leg_" + std::to_string(i) + "-" + std::to_string(j), i, j);
        }
    }

    sm.EnableEarlyTermination();
    sm.SetVisualization(true);
    // sm.SetRealTime(true);

    sm.LoadUrdfString(robot.get_urdf_string());
    sm.RunSimulation();

    std::cout << std::endl << std::endl
              << "=========================================================" << std::endl
              << "The score of this robot: " << sm.GetRootBodyDisplacementX() - 0.5 * std::abs(sm.GetRootBodyDisplacementY()) << std::endl
              << "=========================================================" << std::endl;

    debug_pause();
    return 0;
}
