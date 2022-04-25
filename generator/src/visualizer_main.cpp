#include <iostream>
#include <filesystem>

#include "SimulatorParams.h"
#include "SimulationManager.h"
#include "RobotRepresentation.h"
#include "sferes_gen_EvoGenFloat.hpp"
#include "sferes_phen_EvoGenPhen.hpp"
#include "sferes_fit_UrdfFitness.hpp"
#include "cxxopts.hpp"

#include "evo_paths.h"

typedef sferes::fit::UrdfFitness fit_t;
typedef sferes::phen::EvoGenPhen<sferes::gen::EvoGenFloat, fit_t> phen_t;

// TODO: it seems this visualizer_main can be merged into the user_design_simulator_main
void debug_pause() {
    std::this_thread::sleep_for(std::chrono::seconds(5));
}

int main(int argc, char **argv) {
    cxxopts::Options options("Genotype Visualizer", "Visualizing the performance of genomes");
    options.add_options()
        ("robot_type", "Type of robot, primitive/mesh(default)", cxxopts::value<std::string>()->default_value("mesh"))
        ("sim_param", "Path to sim_params.xml", cxxopts::value<std::string>())
        ("sim_time", "Simulation time. Default 0, to use the sim time in sim_param", cxxopts::value<double>()->default_value("0.0"))
        ("do_realtime", "Run real time simulation (normally slower than none-realtime simualtion)", cxxopts::value<bool>()->default_value("false"))
        ("color", "Color of robot, in RGB", cxxopts::value<std::vector<double>>())
        ("canvas_size", "Size of canvas, [width, height]", cxxopts::value<std::vector<int>>())
        ("camera", "Six doubles that defines the camera angle", cxxopts::value<std::vector<double>>())
        ("design_vector", "Design vector of robot", cxxopts::value<std::vector<double>>())
        ("h,help", "Print usage")
    ;
    auto arg_parsed = options.parse(argc, argv);

    if (arg_parsed.count("sim_param") == 0 ||
        arg_parsed.count("design_vector") == 0)
    {
        std::cout << "Insufficient input. Make sure the sim_param file and design_vector" << std::endl;
        std::cout << options.help() << std::endl;
        return 1;
    }

    if (arg_parsed.count("help")) {
        std::cout << options.help() << std::endl;
        return 0;
    }

    std::string robot_type(arg_parsed["robot_type"].as<std::string>());
    std::string sim_filename(arg_parsed["sim_param"].as<std::string>());
    std::vector<double> gene = arg_parsed["design_vector"].as<std::vector<double>>();

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

    SimulatorParams sim_params;
    sim_params.Load(sim_filename);
    sim_params.env_dir = result_dir;

    SimulationManager sm;

    double time_out = arg_parsed["sim_time"].as<double>();
    if (time_out == 0)
        time_out = sim_params.time_out;
    sm.SetTimeout(time_out);

    if (arg_parsed.count("camera")) {
        sm.SetCamera(arg_parsed["camera"].as<std::vector<double>>());
    } else {
        sm.SetCamera(sim_params.camera_pos[0],
                     sim_params.camera_pos[1],
                     sim_params.camera_pos[2],
                     sim_params.camera_pos[3],
                     sim_params.camera_pos[4],
                     sim_params.camera_pos[5]);
    }
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

    sm.EnableEarlyTermination();
    sm.SetVisualization(true);
    if (arg_parsed.count("color")) // Note the count for vector is the number of vector, not the number of elements!
        sm.SetRobotColor(arg_parsed["color"].as<std::vector<double>>());
    if (arg_parsed.count("canvas_size"))
        sm.SetCanvasSize(arg_parsed["canvas_size"].as<std::vector<int>>());
    sm.SetRealTime(arg_parsed["do_realtime"].as<bool>());

    auto& fit = phen.fit();
    fit.eval(phen, sm);

    if (fit.dead()) {
        std::cout << "Robot is invalid, no score reported" << std::endl;
    } else {
        std::cout << std::endl << std::endl
                  << "=========================================================" << std::endl
                  << "The fitness of this robot: " << fit.value() << std::endl
                  << "=========================================================" << std::endl;
    }

    return 0;
}
