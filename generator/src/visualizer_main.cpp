#include <iostream>
#include <filesystem>

#include "SimulatorParams.h"
#include "SimulationManager.h"
#include "GenerateDemoRobot.h"
#include "GenerateDemoRobogamiRobot.h"
#include "RobotRepresentation.h"

int main(int argc, char **argv) {
    if (argc < 2) {
        std::cout << "Input format: <RobotType: primitive/mesh> <path/to/sim_params.xml> <Design Vector>" << std::endl;
        return 0;
    }

    // arg_cursor = 0 is the exe name
    int arg_cursor = 1;
    std::string robot_type(argv[arg_cursor++]);
    std::string sim_filename(argv[arg_cursor++]);
    std::vector<double> design_vector;
    for (int i = arg_cursor; i < argc; ++i)
        design_vector.push_back(std::atof(argv[arg_cursor++]));

    RobotRepresentation robot(design_vector, 0.5, 1.5);

    SimulatorParams sim_params;
    sim_params.Load(sim_filename);
    sim_params.env_dir = std::filesystem::path(sim_filename).parent_path().string();

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

    for (int i = 0; i < robot.num_legs; ++i) {
        sm.AddEvoGenMotor("chassis_leg_" + std::to_string(i) + "-0", i, 0);
        for (int j = 1; j < robot.legs[i].num_links; ++j) {
            sm.AddEvoGenMotor("leg_" + std::to_string(i) + "-" + std::to_string(j - 1) +
                              "_leg_" + std::to_string(i) + "-" + std::to_string(j), i, j);
        }
    }

    sm.SetVisualization(true);
    // sm.SetRealTime(true);

    // If the result dir contains parts lib, use it
    std::filesystem::path result_dir(sim_filename);
    if (std::filesystem::exists(result_dir.parent_path().string() + "/robot_parts"))
        set_mesh_dir(result_dir.parent_path().string() + "/robot_parts");

    if (robot_type == "primitive") {
        sm.LoadUrdfString(generate_demo_robot_string("leg", robot));
    } else if (robot_type == "mesh") {
        sm.LoadUrdfString(generate_demo_robogami_robot_string("leg", robot));
    } else {
        std::cout << "Error: This visualizer doesn't support robot type " << robot_type << std::endl;
    }
    sm.RunSimulation();
    return 0;
}
