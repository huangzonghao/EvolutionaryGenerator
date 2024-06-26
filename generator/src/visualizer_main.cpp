#include <chrono>
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

// when use_delay == true, the pause would be terminated after certain delay time
void debug_pause(bool use_delay = true) {
    if (use_delay) {
        std::this_thread::sleep_for(std::chrono::seconds(5));
    } else {
        do {
            std::cout << std::endl << "Press Enter to exit";
        } while (!std::cin.get());
    }
}

enum MODE {NORMAL, USER_STUDY, NO_VIS};

int main(int argc, char **argv) {
    cxxopts::Options options("Genotype Visualizer", "Visualizing the performance of genomes");
    options.add_options()
        ("mode", "Mode of visualization, normal(default)/user_study/no_visualization", cxxopts::value<std::string>()->default_value("normal"))
        ("robot_type", "Type of robot, primitive/mesh(default)", cxxopts::value<std::string>()->default_value("mesh"))
        ("environment", "Environemnt to use. Only respected in user_study mode", cxxopts::value<std::string>()->default_value("ground"))
        ("sim_param", "Path to sim_params.xml", cxxopts::value<std::string>())
        ("sim_time", "Simulation time. Default to use the sim time in sim_param", cxxopts::value<double>())
        ("do_realtime", "Run real time simulation (normally slower than none-realtime simualtion)", cxxopts::value<bool>()->default_value("false"))
        ("color", "Color of robot, in RGB", cxxopts::value<std::vector<double>>())
        ("env_color", "Color of environment, in RGB", cxxopts::value<std::vector<double>>())
        ("canvas_size", "Size of canvas, [width, height]", cxxopts::value<std::vector<int>>())
        ("camera", "Six doubles that defines the camera angle", cxxopts::value<std::vector<double>>())
        ("light", "Three doubles that specify the vector for light direction", cxxopts::value<std::vector<double>>())
        ("fov", "A double that define the camera field of view in simulation", cxxopts::value<double>())
        ("frame_output_name", "Name of the exported video frames", cxxopts::value<std::string>())
        ("frame_interval", "Interval of the frames to record, only valid when frame_output_name is set", cxxopts::value<int>()->default_value("20"))
        ("fitness_file", "File path to save the evaluated fitness", cxxopts::value<std::string>())
        ("design_vector", "Design vector of robot", cxxopts::value<std::vector<double>>())
        ("h,help", "Print usage")
    ;

    cxxopts::ParseResult arg_result;
    bool arg_parsed = false;
    if (argc == 2) {
        // this might be the protocol call from browser
        char *protocol_label = NULL;
        protocol_label = strstr(argv[1], "evogen-uisim:");
        if (protocol_label) {
            // TODO: update the cxxopts so that it takes char array and could use
            // customized separator (%20)
            std::string input_cmd(argv[1]);
            std::size_t loc = input_cmd.find("%20");
            while (loc != std::string::npos) {
                input_cmd.replace(loc, 3, " ");
                loc = input_cmd.find("%20");
            }
            input_cmd.erase(0, 14); // remove the initial 'evogen-uisim: '
            arg_result = options.parse(input_cmd);
            arg_parsed = true;
        }
    }

    if (!arg_parsed) {
        arg_result = options.parse(argc, argv);
    }

    if (arg_result.count("design_vector") == 0) {
        std::cout << "Error: Insufficient input, no design vector" << std::endl;
        std::cout << options.help() << std::endl;
        debug_pause(false);
        return 1;
    }

    if (arg_result.count("help")) {
        std::cout << options.help() << std::endl;
        return 0;
    }

    int mode = 0;
    if (arg_result["mode"].as<std::string>() == "user_study") {
        mode = USER_STUDY;
    } else if (arg_result["mode"].as<std::string>() == "no_visualization") {
        mode = NO_VIS;
    } else {
        mode = NORMAL;
    }

    std::string robot_type(arg_result["robot_type"].as<std::string>());

    std::string env_dir = EvoGen_Maps_Dir;
    std::string mesh_dir = Robot_Parts_Dir;
    double phen_min = 0.5;
    double phen_max = 1.5;
    SimulatorParams sim_params;
    if (arg_result.count("sim_param") == 0) {
        sim_params.Load(EvoGen_Params_Dir + "/sim_params.xml");
    } else {
        sim_params.Load(arg_result["sim_param"].as<std::string>());
        std::string result_dir = std::filesystem::path(arg_result["sim_param"].as<std::string>()).parent_path().string();
        // If the given sim_param locates in a result_dir, then use all resources
        // from that result_dir
        if (std::filesystem::exists(result_dir + "/robot_parts"))
            mesh_dir = result_dir + "/robot_parts";
        if (std::filesystem::exists(result_dir + "/evo_params.xml")) {
            EvoParams evo_params;
            evo_params.Load(result_dir + "/evo_params.xml");
            phen_min = evo_params.phen_data_min();
            phen_max = evo_params.phen_data_max();
        }
        env_dir = result_dir;
    }

    sim_params.env_dir = env_dir;

    if (mode == USER_STUDY) {
        sim_params.SetEnv(arg_result["environment"].as<std::string>());
    }

    mesh_info.set_mesh_dir(mesh_dir);
    // Note: the mesh_info must be ready when phen develops the robot
    mesh_info.init();

    phen_t phen(arg_result["design_vector"].as<std::vector<double>>(), phen_min, phen_max);
    phen.develop();

    SimulationManager sm;

    // user specified sim_time presides the defaults in the sim_params
    if (arg_result.count("sim_time"))
        sm.SetTimeout(arg_result["sim_time"].as<double>());
    else
        sm.SetTimeout(sim_params.time_out);

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
    if (mode == NO_VIS) {
        sm.SetVisualization(false);
    } else {
        if (arg_result.count("camera")) {
            sm.SetCamera(arg_result["camera"].as<std::vector<double>>());
        } else {
            sm.SetCamera(sim_params.camera_pos[0],
                         sim_params.camera_pos[1],
                         sim_params.camera_pos[2],
                         sim_params.camera_pos[3],
                         sim_params.camera_pos[4],
                         sim_params.camera_pos[5]);
        }
        if (arg_result.count("light"))
            sm.SetLight(arg_result["light"].as<std::vector<double>>());
        if (arg_result.count("fov"))
            sm.SetFOV(arg_result["fov"].as<double>());
        if (arg_result.count("frame_output_name"))
            sm.RecordVideoFrames(arg_result["frame_interval"].as<int>(),
                                 arg_result["frame_output_name"].as<std::string>());
        if (arg_result.count("color")) // Note the count for vector is the number of vector, not the number of elements!
            sm.SetRobotColor(arg_result["color"].as<std::vector<double>>());
        if (arg_result.count("env_color"))
            sm.SetEnvColor(arg_result["env_color"].as<std::vector<double>>());
        if (arg_result.count("canvas_size"))
            sm.SetCanvasSize(arg_result["canvas_size"].as<std::vector<int>>());
        sm.SetRealTime(arg_result["do_realtime"].as<bool>());
        sm.SetVisualization(true);
    }

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

    // Save the fitness to the path
    if (arg_result.count("fitness_file")) {
        std::ofstream ofs(arg_result["fitness_file"].as<std::string>(), std::ofstream::out | std::ofstream::app);
        ofs << fit.value() << std::endl;
        ofs.close();
    }

    if (mode == USER_STUDY) {
        debug_pause();
    }

    return 0;
}
