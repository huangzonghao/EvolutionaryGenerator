#include <iostream>
#include <filesystem>

#include "SimulatorParams.h"
#include "SimulationManager.h"
#include "RobotRepresentation.h"
#include "sferes_gen_EvoGenFloat.hpp"
#include "sferes_phen_EvoGenPhen.hpp"
#include "sferes_fit_UrdfFitness.hpp"

#include "evo_paths.h"

typedef sferes::fit::UrdfFitness fit_t;
typedef sferes::phen::EvoGenPhen<sferes::gen::EvoGenFloat, fit_t> phen_t;

int main(int argc, char **argv) {
    if (argc < 2) {
        std::cout << "Input format: <RobotType: primitive/mesh> <path/to/sim_params.xml> <Design Vector>" << std::endl;
        return 0;
    }

    // arg_cursor = 0 is the exe name
    int arg_cursor = 1;
    std::string robot_type(argv[arg_cursor++]);
    std::string sim_filename(argv[arg_cursor++]);
    std::vector<double> gene;
    for (int i = arg_cursor; i < argc; ++i)
        gene.push_back(std::atof(argv[arg_cursor++]));

    std::string result_dir = std::filesystem::path(sim_filename).parent_path().string();
    // If the result dir contains parts lib, use it
    // Note: the mesh_info must be ready when phen develops the robot
    if (std::filesystem::exists(result_dir + "/robot_parts"))
        mesh_info.set_mesh_dir(result_dir + "/robot_parts");
    else
        mesh_info.set_mesh_dir(Robot_Parts_Dir);

    mesh_info.init();

    EvoParams evo_params;
    evo_params.Load(result_dir + "/evo_params.xml");
    phen_t phen(gene, evo_params.phen_data_min(), evo_params.phen_data_max());
    phen.develop();
    const auto& robot = phen.get_robot();

    SimulatorParams sim_params;
    sim_params.Load(sim_filename);
    sim_params.env_dir = result_dir;

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

    sm.SetVisualization(true);
    // sm.SetRealTime(true);

    sm.LoadUrdfString(robot.get_urdf_string());
    sm.RunSimulation();
    return 0;
}
