#include <iostream>
#include <filesystem>

#include "SimulatorParams.h"
#include "SimulationManager.h"
#include "GenerateDemoRobot.h"

int main(int argc, char **argv) {
    if (argc < 2 || argc > 9) {
        std::cout << "Input format: <path/to/sim_params.xml> <Design Vector>" << std::endl;
        return 0;
    }

    std::string sim_filename(argv[1]);
    std::vector<float> design_vector;
    for (int i = 2; i < 9; ++i)
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

    sm.AddMotor("MOTOR", "chassis", "chassis_wheel_fl", 1,0.1,0.1,0.1);
    sm.AddMotor("MOTOR", "chassis", "chassis_wheel_rl", 1,0.1,0.1,0.1);
    sm.AddMotor("MOTOR", "chassis", "chassis_wheel_fr", 1,0.1,0.1,0.1);
    sm.AddMotor("MOTOR", "chassis", "chassis_wheel_rr", 1,0.1,0.1,0.1);

    sm.SetVisualization(true);
    // sm.SetRealTime(true);

    sm.LoadUrdfString(generate_demo_robot_string("leg", design_vector));
    sm.RunSimulation();
    return 0;
}
