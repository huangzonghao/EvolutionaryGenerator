#include <algorithm> // std::replace
#include <regex>
#include <iostream>
#include <fstream>
#include <sstream>
#include <filesystem>
#include <rapidjson/document.h>

#include "SimulatorParams.h"
#include "EvoParams.h"
#include "EvoGenerator.h"

#include "evo_paths.h"

void new_training(bool use_user_seeds) {
    EvoGenerator evo_gen;
    EvoParams evo_params;
    SimulatorParams sim_params;
    bool need_to_return = false;
    std::filesystem::path sim_params_path(EvoGen_Params_Dir + "/sim_params.xml");
    if (std::filesystem::exists(sim_params_path)) {
        sim_params.Load(sim_params_path.string());
    } else {
        sim_params.Save(sim_params_path.string());
        need_to_return = true;
    }
    std::filesystem::path evo_params_path(EvoGen_Params_Dir + "/evo_params.xml");
    if (std::filesystem::exists(evo_params_path)) {
        evo_params.Load(evo_params_path.string());
    } else {
        evo_params.Save(evo_params_path.string());
        need_to_return = true;
    }

    if (need_to_return) {
        std::cout << "Params files write to " << EvoGen_Params_Dir << std::endl;
        std::cout << "Edit those files and relaunch" << std::endl;
        return;
    }

    // set up output dir
    time_t t = time(0);
    char time_buffer [80];
    strftime(time_buffer, 80, "%Y%m%d_%H%M%S", localtime(&t));

    std::string env_name_converted(sim_params.env_name);
    std::replace(env_name_converted.begin(), env_name_converted.end(), '.', '_');
    std::string log_dir = Result_Output_Dir + "/" + env_name_converted + "_" +
                          "P" + std::to_string(evo_params.pop_size()) +
                          "G" + std::to_string(evo_params.nb_gen()) + "_" +
                          std::to_string(evo_params.grid_shape()[0]) + "x" +
                          std::to_string(evo_params.grid_shape()[1]) +
                          "_" + time_buffer;

    sim_params.env_dir = EvoGen_Maps_Dir;
    sim_params.parts_dir = Robot_Parts_Dir;

    // copy env file and robot_parts file here
    if (evo_params.output_enabled()) {
        std::filesystem::create_directories(log_dir);
        const std::string& env_file = sim_params.GetEnv();
        if (std::filesystem::exists(env_file)) { // in case env is ground
            std::filesystem::copy(env_file, log_dir);
            sim_params.env_dir = log_dir;
        }

        std::filesystem::copy(Robot_Parts_Dir, log_dir + "/robot_parts", std::filesystem::copy_options::recursive);
        sim_params.parts_dir = log_dir + "/robot_parts";
    }

    if (use_user_seeds) {
        auto user_seeds = std::make_shared<std::vector<std::vector<double>>>();
        std::string seed_dir(log_dir + "/user_inputs");
        std::filesystem::create_directories(seed_dir);
        // load the user seeds and copy them into result_dir
        const int max_num_user_inputs = 30;
        rapidjson::Document jdoc;
        for (const auto& entry : std::filesystem::directory_iterator(User_Input_Dir)) {
            if (entry.path().extension().string() == ".txt") {
                std::filesystem::copy(entry.path(), seed_dir);

                std::ifstream infile(entry.path());
                std::stringstream ss;
                ss << infile.rdbuf();
                jdoc.Parse(ss.str().c_str());
                const rapidjson::Value& js_gene = jdoc["gene"];
                std::vector<double> gene(js_gene.Size());
                for (int i = 0; i < gene.size(); ++i) {
                    gene[i] = js_gene[i].GetDouble();
                }
                user_seeds->push_back(gene);

                if (user_seeds->size() >= max_num_user_inputs)
                    break;
            }
        }
        evo_gen.set_user_seeds(user_seeds);
    }

    evo_gen.set_evo_params(evo_params);
    evo_gen.set_sim_params(sim_params);
    evo_gen.set_result_dir(log_dir);

    evo_gen.run();
}

void resume_training(const std::string& result_dir_basename) {
    std::string result_dir(Result_Output_Dir + "/" + result_dir_basename);
    std::regex rx(".*gen_([0-9]+).*");
    std::smatch match;
    int last_gen = -1;
    for (const auto& entry : std::filesystem::directory_iterator(result_dir + "/dumps")) {
        std::string tmp_path(entry.path().string());
        if (std::regex_match(tmp_path, match, rx)) {
            int curr_gen = std::stoi(match[1].str());
            if (curr_gen > last_gen)
                last_gen = curr_gen;
        }
    }

    EvoGenerator evo_gen;
    evo_gen.resume(result_dir, last_gen);
}

int main(int argc, char **argv) {
    if (argc < 2) {
        const auto& exe_name = std::filesystem::path(std::string(argv[0])).filename().string();
        std::cout << "Usage:"  << std::endl;
        std::cout << "    1) To start new training with random seeds: " << exe_name << " new"  << std::endl;
        std::cout << "    2) To start new training with user seeds: " << exe_name << " new user"  << std::endl;
        std::cout << "    3) To resume an existing training: " << exe_name << " resume <result_dir_basename>"  << std::endl;
        return 0;
    }
    std::string mode(argv[1]);
    if (mode == "new") {
        new_training(argc > 2 && std::string(argv[2]) == "user");
    } else if (mode == "resume") {
        resume_training(std::string(argv[2]));
    } else {
        std::cout << "Error: wrong mode " << mode << std::endl;
    }
    return 0;
}
