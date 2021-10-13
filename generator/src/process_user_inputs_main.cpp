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
    }

}
void process_user_inputs(const std::filesystem::path& dir_path) {
    std::cout << "Processing " << dir_path.stem().string() << std::endl;

    std::vector<std::filesystem::path> design_files;
    for (const auto& entry : std::filesystem::directory_iterator(dir_path)) {
        if (entry.path().filename().string().find("evogen_") != std::string::npos) {
            design_files.push_back(entry);
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

    json output_jsobj;

    // Add meta info
    output_jsobj["user_id"] = jsobjs[0]["user_id"];

    for (int i = 0; i < design_files.size(); ++i) {
        auto& jsobj = jsobjs[i];
        auto& tmp_jsobj = output_jsobj["designs"][jsobj["environment"].get<std::string>()][std::to_string(jsobj["ver"].get<int>())];
        tmp_jsobj["gene"] = jsobj["gene"];
        tmp_jsobj["fitness"] = reports[i].fitness;
    }

    std::ofstream ofs(User_Input_Dir + "/" + dir_path.stem().string() + ".json");
    ofs << output_jsobj.dump() << std::endl; // the number in json::dump specifies indention
    ofs.close();
}

int main(int argc, char **argv) {
    std::vector<std::filesystem::path> dirs;
    int counter = 0;
    for (const auto& entry : std::filesystem::directory_iterator(User_Input_Dir)) {
        if (std::filesystem::is_directory(entry)) {
            dirs.push_back(entry);
            std::cout << counter++ << ")" << entry.path().stem().string() << std::endl;
        }
    }

    mesh_info.set_mesh_dir(Robot_Parts_Dir);
    mesh_info.init();

    int user_input = -1;
    while (user_input < 0 || user_input > dirs.size() - 1) {
        std::cout << "Select user study dir: ";
        std::cin >> user_input;
    }
    process_user_inputs(dirs[user_input]);

    return 0;
}

