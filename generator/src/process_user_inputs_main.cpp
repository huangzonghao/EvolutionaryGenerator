// This file evaluates the user designs and generates one json file containing
// all the user designed the robot, their fitness and some other meta info
#include <iostream>
#include <fstream>
#include <sstream>
#include <filesystem>
#include <thread>
#include <nlohmann/json.hpp>

#include "SimulatorParams.h"
#include "SimulationManager.h"
#include "RobotRepresentation.h"
#include "sferes_gen_EvoGenFloat.hpp"
#include "sferes_fit_UrdfFitness.hpp"
#include "sferes_phen_EvoGenPhen.hpp"

#include "evo_paths.h"

using json = nlohmann::json;
typedef sferes::fit::UrdfFitness fit_t;
typedef sferes::phen::EvoGenPhen<sferes::gen::EvoGenFloat, fit_t> phen_t;

// TODO: find a way to directly convert and include this struct to json obj
// probably implement a nlohmann_json parser for it
class EvalReport {
  public:
    std::vector<double> feature = {0.0, 0.0};
    double fitness = 0;
};

void eval_kernel(const std::vector<std::filesystem::path>& design_files,
                 std::vector<json>& jsobjs,
                 std::vector<EvalReport>& reports,
                 const EvoParams& evo_params,
                 SimulatorParams sim_params,
                 int start_idx, int end_idx) {

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

    sm.SetRealTime(sim_params.do_realtime);
    sm.SetVisualization(false);

    for (int i = start_idx; i < end_idx; ++i) {
        auto& jsobj = jsobjs[i];
        auto& report = reports[i];

        std::ifstream ifs(design_files[i]);
        jsobj = json::parse(ifs);

        phen_t phen(jsobj["gene"], evo_params.phen_data_min(), evo_params.phen_data_max());
        phen.develop();

        sim_params.SetEnv(jsobj["environment"]);
        sm.SetEnv(sim_params.GetEnv(),
                  sim_params.env_dim[0],
                  sim_params.env_dim[1],
                  sim_params.env_dim[2]);

        auto& fit = phen.fit();
        fit.eval(phen, sm);

        report.fitness = fit.value();
        report.feature = fit.desc();
    }

}
void process_user_inputs(const std::filesystem::path& dir_path) {
    std::cout << "Processing " << dir_path.stem().string() << std::endl;

    std::filesystem::path meta_file;
    std::vector<std::filesystem::path> design_files;
    for (const auto& entry : std::filesystem::directory_iterator(dir_path)) {
        if (entry.path().filename().string().find("evogen_") != std::string::npos) {
            design_files.push_back(entry);
        } else if (entry.path().filename().string().find("UserStudy_") != std::string::npos) {
            meta_file = entry.path();
        }
    }
    std::vector<EvalReport> reports(design_files.size());
    std::vector<json> jsobjs(design_files.size());

    EvoParams evo_params;
    evo_params.Load(EvoGen_Params_Dir + "/evo_params.xml");

    SimulatorParams sim_params;
    sim_params.Load(EvoGen_Params_Dir + "/sim_params.xml");
    sim_params.env_dir = EvoGen_Maps_Dir;

    int num_threads = std::thread::hardware_concurrency();
    int batch_size = design_files.size() / num_threads;
    int num_leftovers = design_files.size() - batch_size * num_threads;
    int element_cursor = 0;
    std::vector<std::shared_ptr<std::thread>> threads(num_threads);
    for (int i = 0; i < num_leftovers; ++i) {
        threads[i] = std::make_shared<std::thread>(eval_kernel, std::cref(design_files), std::ref(jsobjs), std::ref(reports),
                                                   std::ref(evo_params), sim_params, element_cursor, element_cursor + batch_size + 1);
        element_cursor += batch_size + 1;
    }
    for (int i = num_leftovers; i < num_threads; ++i) {
        threads[i] = std::make_shared<std::thread>(eval_kernel, std::cref(design_files), std::ref(jsobjs), std::ref(reports),
                                                   std::ref(evo_params), sim_params, element_cursor, element_cursor + batch_size);
        element_cursor += batch_size;
    }

    for (auto& thread : threads)
        thread->join();

    std::ifstream ifs(meta_file);
    json meta_jsobj = json::parse(ifs);
    json output_jsobj;

    // Add meta info
    output_jsobj["user_id"] = jsobjs[0]["user_id"];
    output_jsobj["env_string"] = meta_jsobj["env_string"];
    output_jsobj["feature_description"] = {fit_t::descriptor_name[0], fit_t::descriptor_name[1]};

    for (int i = 0; i < design_files.size(); ++i) {
        auto& jsobj = jsobjs[i];
        auto& tmp_jsobj = output_jsobj["designs"][jsobj["environment"].get<std::string>()][std::to_string(jsobj["ver"].get<int>())];
        tmp_jsobj["gene"] = jsobj["gene"];
        tmp_jsobj["fitness"] = reports[i].fitness;
        tmp_jsobj["feature"] = reports[i].feature;
    }

    std::ofstream ofs(User_Input_Dir + "/" + dir_path.stem().string() + ".json");
    ofs << output_jsobj.dump() << std::endl; // the number in json::dump specifies indention
    ofs.close();

    // TODO: for some reason the following code to move dirs doesn't work (only tested on windows)
    // Move the processed user input to the archive directory
    // std::string archive_dir = User_Input_Dir + "/Processed";
    // if (!std::filesystem::exists(archive_dir)) {
        // std::filesystem::create_directories(archive_dir);
    // }
    // std::filesystem::rename(dir_path, archive_dir + "/" + dir_path.stem().string());
}

int main(int argc, char **argv) {
    std::string input_dir(User_Input_Dir + "/Raw");
    if (!std::filesystem::exists(input_dir)) {
        std::cout << "Error: " << input_dir << " doesn't exist" << std::endl;
        return -1;
    }
    std::vector<std::filesystem::path> dirs;
    for (const auto& entry : std::filesystem::directory_iterator(input_dir)) {
        if (std::filesystem::is_directory(entry)) {
            dirs.push_back(entry);
        }
    }

    if (dirs.size() == 0) {
        std::cout << "No user input found" << std::endl
                  << "Put user inputs into " << input_dir + "/<6-digit-user-id>" << std::endl;
        return 0;
    }

    mesh_info.set_mesh_dir(Robot_Parts_Dir);
    mesh_info.init();

    for (int i = 0; i < dirs.size(); ++i) {
        std::cout << i + 1 << " / " << dirs.size() << std::endl;
        process_user_inputs(dirs[i]);
    }
    std::cout << "All user inputs processed. Exit" << std::endl;

    return 0;
}

