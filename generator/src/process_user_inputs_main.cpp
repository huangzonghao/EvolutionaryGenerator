// This file evaluates the user designs and generates one json file containing
// all the user designed the robot, their fitness and some other meta info
#include <iostream>
#include <fstream>
#include <sstream>
#include <filesystem>
#include <thread>

#define RAPIDJSON_HAS_STDSTRING 1
#include <rapidjson/document.h>
#include <rapidjson/filewritestream.h>
#include <rapidjson/prettywriter.h>

#include "SimulatorParams.h"
#include "SimulationManager.h"
#include "RobotRepresentation.h"
#include "sferes_gen_EvoGenFloat.hpp"
#include "sferes_fit_UrdfFitness.hpp"
#include "sferes_phen_EvoGenPhen.hpp"

#include "evo_paths.h"

typedef sferes::fit::UrdfFitness fit_t;
typedef sferes::phen::EvoGenPhen<sferes::gen::EvoGenFloat, fit_t> phen_t;

class EvalReport {
  public:
    double fitness = 0;
};

void eval_kernel(const std::vector<std::filesystem::path>& design_files,
                 std::vector<rapidjson::Document>& jdocs,
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
        auto& jdoc = jdocs[i];
        auto& report = reports[i];

        std::ifstream infile(design_files[i]);
        std::stringstream ss;
        ss << infile.rdbuf();
        jdoc.Parse(ss.str().c_str());
        const rapidjson::Value& js_gene = jdoc["gene"];
        std::vector<double> gene;
        gene.resize(js_gene.Size());
        for (int i = 0; i < gene.size(); ++i) {
            gene[i] = js_gene[i].GetDouble();
        }

        phen_t phen(gene, evo_params.phen_data_min(), evo_params.phen_data_max());
        phen.develop();
        const auto& robot = phen.get_robot();

        sim_params.SetEnv(jdoc["environment"].GetString());
        sm.SetEnv(sim_params.GetEnv(),
                  sim_params.env_dim[0],
                  sim_params.env_dim[1],
                  sim_params.env_dim[2]);

        sm.RemoveAllMotors();
        for (int i = 0; i < robot.num_legs(); ++i) {
            sm.AddEvoGenMotor("chassis_leg_" + std::to_string(i) + "-0", i, 0);
            for (int j = 1; j < robot.legs[i].num_links; ++j) {
                sm.AddEvoGenMotor("leg_" + std::to_string(i) + "-" + std::to_string(j - 1) +
                                  "_leg_" + std::to_string(i) + "-" + std::to_string(j), i, j);
            }
        }

        sm.LoadUrdfString(robot.get_urdf_string());
        sm.RunSimulation();

        report.fitness = sm.GetRootBodyDisplacementX() - 0.5 * std::abs(sm.GetRootBodyDisplacementY());
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
    std::vector<rapidjson::Document> jdocs(design_files.size());

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
    // TODO: merge the following two for loops into one
    for (int i = 0; i < num_leftovers; ++i) {
        threads[i] = std::make_shared<std::thread>(eval_kernel, std::cref(design_files), std::ref(jdocs), std::ref(reports),
                                                   std::ref(evo_params), sim_params, element_cursor, element_cursor + batch_size + 1);
        element_cursor += batch_size + 1;
    }
    for (int i = num_leftovers; i < num_threads; ++i) {
        threads[i] = std::make_shared<std::thread>(eval_kernel, std::cref(design_files), std::ref(jdocs), std::ref(reports),
                                                   std::ref(evo_params), sim_params, element_cursor, element_cursor + batch_size);
        element_cursor += batch_size;
    }

    for (auto& thread : threads)
        thread->join();

    rapidjson::Document output_jdoc;
    output_jdoc.SetObject(); // without this you won't be able to add member to the dom tree
    auto& output_allocator = output_jdoc.GetAllocator();

    // Add meta info
    // TODO: The following four lines to set up the user id in the new document is
    // simply too complicated and stupid
    std::string user_id = jdocs[0]["user_id"].GetString();
    rapidjson::Value user_id_v(rapidjson::kObjectType);
    user_id_v.SetString(rapidjson::StringRef(user_id.c_str()));
    output_jdoc.AddMember("user_id", user_id_v, output_allocator);

    rapidjson::Value ground_g(rapidjson::kObjectType);
    rapidjson::Value sine_g(rapidjson::kObjectType);
    rapidjson::Value valley_g(rapidjson::kObjectType);
    for (int i = 0; i < design_files.size(); ++i) {
        auto& jdoc = jdocs[i];
        // TODO: figure out a way to automatically generate env groups
        // const auto& jdoc = jdocs[i];
        // const auto& env = jdoc["environment"];
        // std::string env_str = env.GetString();
        // if (!output_jdoc.HasMember(env)) {
            // output_jdoc.AddMember(env_str, rapidjson::Value(rapidjson::kObjectType), output_allocator);
        // }
        // auto& env_group = output_jdoc[env];
        // env_group.AddMember(jdoc["ver"], jdoc["gene"], output_allocator);
        rapidjson::Value fit_v(rapidjson::kObjectType);
        fit_v.SetDouble(reports[i].fitness);
        jdoc.AddMember("fitness", fit_v, jdocs[i].GetAllocator());
        // auto key = rapidjson::Value(std::to_string(i), output_allocator); // need to do this due to stupid rapidjson design https://github.com/Tencent/rapidjson/issues/261
        // output_jdoc.AddMember(key, jdocs[i], output_allocator);
        std::string env = jdoc["environment"].GetString();

        // Remove uncessary fields
        auto ver_key = rapidjson::Value(std::to_string(jdoc["ver"].GetInt()), output_allocator); // need to do this due to stupid rapidjson design https://github.com/Tencent/rapidjson/issues/261
        if (env == "ground") {
            ground_g.AddMember(ver_key, jdoc, output_allocator);
        } else if (env == "Sine2.obj") {
            sine_g.AddMember(ver_key, jdoc, output_allocator);
        } else if (env == "Valley5.obj") {
            valley_g.AddMember(ver_key, jdoc, output_allocator);
        }
    }
    output_jdoc.AddMember("ground", ground_g, output_allocator);
    output_jdoc.AddMember("Sine2.obj", sine_g, output_allocator);
    output_jdoc.AddMember("Valley5.obj", valley_g, output_allocator);

    rapidjson::StringBuffer strbuf;
    rapidjson::PrettyWriter<rapidjson::StringBuffer> writer(strbuf);
    writer.SetFormatOptions(rapidjson::kFormatSingleLineArray);
    output_jdoc.Accept(writer);

    std::ofstream ofs(User_Input_Dir + "/" + dir_path.stem().string() + ".json");
    ofs << strbuf.GetString() << std::endl;
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

