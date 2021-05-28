#include <iostream>
#include <filesystem>

#include "SimulatorParams.h"
#include "SimulationManager.h"
#include "GenerateDemoRobot.h"

int main(int argc, char **argv) {
    if (argc < 2) {
        std::cout << "Input format: <path/to/sim_params.xml> <Design Vector>" << std::endl;
        return 0;
    }

    std::string sim_filename(argv[1]);
    std::vector<double> design_vector;
    for (int i = 2; i < argc; ++i)
        design_vector.push_back(std::atof(argv[i]));

    SimulatorParams sim_params;
    sim_params.Load(sim_filename);

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

    sm.SetEnv(sim_params.env_name,
              sim_params.env_dim[0],
              sim_params.env_dim[1],
              sim_params.env_dim[2]);
    sm.SetEnvRot(sim_params.env_rot[0],
                 sim_params.env_rot[1],
                 sim_params.env_rot[2],
                 sim_params.env_rot[3]);

    int num_links;
    int num_legs = design_vector[3];
    int cursor = 5;
    // the leg order in Phen is: FL FR ML MR BL BR
    // the leg order in Sim Controller is: FL ML BL BR MR FR
    // so the conversion happens here
    for (int i = 0; i < num_legs / 2; ++i) {
        num_links = design_vector[cursor];
        sm.AddEvoGenMotor("chassis_leg_" + std::to_string(2 * i) + "-0", i, 0);
        for (int j = 1; j < num_links; ++j) {
            sm.AddEvoGenMotor("leg_" + std::to_string(2 * i) + "-" + std::to_string(j - 1) +
                                "_leg_" + std::to_string(2 * i) + "-" + std::to_string(j), i, j);
        }
        cursor += num_links * 2 + 2; // offsets include leg_pos and num_links

        // the mirrored leg
        num_links = design_vector[cursor];
        sm.AddEvoGenMotor("chassis_leg_" + std::to_string(2 * i + 1) + "-0", num_legs - 1 - i, 0);
        for (int j = 1; j < num_links; ++j) {
            sm.AddEvoGenMotor("leg_" + std::to_string(2 * i + 1) + "-" + std::to_string(j - 1) +
                                "_leg_" + std::to_string(2 * i + 1) + "-" + std::to_string(j), num_legs - 1 - i, j);
        }
        cursor += num_links * 2 + 2; // offsets include leg_pos and num_links
    }

    sm.SetVisualization(true);
    // sm.SetRealTime(true);

    sm.LoadUrdfString(generate_demo_robot_string("leg", design_vector));
    sm.RunSimulation();
    return 0;
}
