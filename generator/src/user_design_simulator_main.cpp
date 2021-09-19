#include <iostream>
#include <fstream>
#include <sstream>
#include <filesystem>

#include <rapidjson/document.h>

#include "SimulatorParams.h"
#include "SimulationManager.h"
#include "RobotRepresentation.h"
#include "sferes_gen_EvoGenFloat.hpp"
#include "sferes_fit_UrdfFitness.hpp"
#include "sferes_phen_EvoGenPhen.hpp"

#include "evo_paths.h"

typedef sferes::fit::UrdfFitness fit_t;
typedef sferes::phen::EvoGenPhen<sferes::gen::EvoGenFloat, fit_t> phen_t;

bool user_input_demo(const std::string& input_dir) {
    std::vector<std::string> filenames;
    int counter = 0;
    for (const auto& entry : std::filesystem::directory_iterator(input_dir)) {
        try {
            std::string filename(entry.path().filename().string());
            if (filename.find("evogen_") != std::string::npos) {
                std::cout << counter++ << ") " << filename << std::endl;
                filenames.push_back(filename);
            }
        } catch (const std::system_error) {
            // This error would be thrown if filename contains non-utf8 characters
            // And none of our files would contain those characters, so we can
            // safely ignore this error.
        }
    }

    char user_input = '0';
    int selected_id = 0;
    while (true) {
        std::cout << "Select robot ('r' to refresh, 'q' to quit): ";
        std::cin >> user_input;
        if (user_input == 'r') {
            return true; // loop again
        } else if (user_input == 'q') {
            return false; // exit program
        } else {
            selected_id = user_input - '0';
            if (selected_id > -1 && selected_id < counter) {
                break;
            } else {
                std::cout << "Invalid input: " << user_input << std::endl;
            }
        }
    }

    std::cout << "Selected: " << filenames[selected_id] << std::endl;

    std::ifstream infile(input_dir + "/" + filenames[selected_id]);
    std::stringstream ss;
    ss << infile.rdbuf();
    rapidjson::Document jdoc;
    jdoc.Parse(ss.str().c_str());
    const rapidjson::Value& js_gene = jdoc["gene"];
    std::vector<double> gene(js_gene.Size());
    for (int i = 0; i < gene.size(); ++i)
        gene[i] = js_gene[i].GetDouble();

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
    sim_params.SetEnv(jdoc["environment"].GetString());

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

    return true;
}

int main(int argc, char **argv) {
    for (int i = 0; i < argc; ++i) {
        std::cout << argv[i] << std::endl;
    }
    system("pause");
    return 0;

    std::string user_input_dir;
    if (argc > 1) {
        user_input_dir = std::string(argv[1]);
    } else {
        user_input_dir = User_Input_Dir;
    }
    while (true) {
        if (!user_input_demo(user_input_dir))
            break;
    }
    return 0;
}
