#include <algorithm> // std::replace
#include <regex>
#include <iostream>
#include <fstream>
#include <sstream>
#include <filesystem>
#include <nlohmann/json.hpp>

#include "SimulatorParams.h"
#include "EvoParams.h"
#include "TrainingConfigs.h"
#include "EvoGenerator.h"

#include "evo_paths.h"

using json = nlohmann::json;

void new_training(EvoParams& evo_params,
                  SimulatorParams& sim_params,
                  const std::string& bagfile_basename,
                  const std::string& result_dir) {

    EvoGenerator evo_gen;

    std::string log_dir;
    if (result_dir.empty()) {
        // set up output dir
        time_t t = time(0);
        char time_buffer [80];
        strftime(time_buffer, 80, "%Y%m%d_%H%M%S", localtime(&t));
        std::string env_name_converted(sim_params.env_name);
        std::replace(env_name_converted.begin(), env_name_converted.end(), '.', '_');
        log_dir = Result_Output_Dir + "/" + env_name_converted + "_" +
                  "P" + std::to_string(evo_params.pop_size()) +
                  "G" + std::to_string(evo_params.nb_gen()) + "_" +
                  std::to_string(evo_params.grid_shape()[0]) + "x" +
                  std::to_string(evo_params.grid_shape()[1]) +
                  "_" + time_buffer;
    } else {
        log_dir = result_dir;
    }

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

        // copy git commit hash
        std::filesystem::copy(EvoGen_Workspace_Dir + "/git_commit_hash.txt", log_dir);
    }

    if (bagfile_basename != "") {
        // Inject user seeds
        std::string bagfile_fullpath(User_Input_Dir + "/Bags/" + bagfile_basename + ".json");
        if (!std::filesystem::exists(bagfile_fullpath)) {
            std::cout << "evo_main Error: " << bagfile_fullpath << " doesn't exist" << std::endl;
            return;
        }

        auto user_seeds = std::make_shared<std::vector<std::vector<double>>>();
        if (evo_params.output_enabled())
            std::filesystem::copy(bagfile_fullpath, log_dir + "/" + bagfile_basename + ".json");

        std::ifstream ifs(bagfile_fullpath);
        json jsobj = json::parse(ifs);

        std::cout << "Training with bag file " << bagfile_basename << ", total seed count " << jsobj["total_count"] << std::endl;

        for (int i = 1; i < jsobj["total_count"].get<int>() + 1; ++i)
            user_seeds->push_back(jsobj["x" + std::to_string(i)]["gene"]);

        evo_gen.set_user_seeds(user_seeds);
    }

    evo_gen.set_evo_params(evo_params);
    evo_gen.set_sim_params(sim_params);
    evo_gen.set_result_dir(log_dir);

    evo_gen.run();
}

void new_training_from_cmd(const std::string& bagfile_basename) {
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

    new_training(evo_params, sim_params, bagfile_basename, std::string());
}

void new_training_from_job(EvoGenTrainingConfigs& training_configs,
                           const std::string& bagfile_basename) {
    EvoParams evo_params;
    SimulatorParams sim_params;

    // TODO: Currently still reading in values like camera_pos, start_pos, ground size, etc
    // from the on disk files. Need to either specify those values in the job file,
    // or hardcode them into program defaults
    std::filesystem::path sim_params_path(EvoGen_Params_Dir + "/sim_params.xml");
    sim_params.Load(sim_params_path.string());
    std::filesystem::path evo_params_path(EvoGen_Params_Dir + "/evo_params.xml");
    evo_params.Load(evo_params_path.string());

    evo_params.set_nb_gen(training_configs.num_gen());
    evo_params.set_pop_size(training_configs.pop_size());

    sim_params.SetEnv(training_configs.env());
    sim_params.SetTimeout(training_configs.sim_time());

    new_training(evo_params, sim_params, bagfile_basename, training_configs.output_dir());
}

void resume_training(const std::string& result_dir) {
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

void resume_from_cmd(const std::string& result_dir_basename) {
    std::string result_dir(Result_Output_Dir + "/" + result_dir_basename);
    resume_training(result_dir);
}

void resume_from_job(const std::string& result_dir) {
    resume_training(result_dir);
}

void process_job_file(const std::string& job_file_basename) {
    std::string jobfile_fullpath(Job_File_Dir + "/" + job_file_basename + ".json");
    if (!std::filesystem::exists(jobfile_fullpath)) {
        std::cout << "evo_main Error: " << jobfile_fullpath << " doesn't exist" << std::endl;
        return;
    }

    std::ifstream ifs(jobfile_fullpath);
    json jsobj = json::parse(ifs);
    ifs.close();
    std::cout << "Loaded job file " << job_file_basename
              << ", job count " << jsobj["job_count"]
              << ", current job " << jsobj["current_job"] << std::endl;

    time_t t = time(0);
    char time_buffer [80];
    bool start_new_job = false;
    std::string group_name(jsobj["group_name"]);
    // prepare for the output fstream
    std::ofstream ofs;
    for (int i = jsobj["current_job"].get<int>(); i < jsobj["job_count"].get<int>() + 1; ++i) {
        auto& job = jsobj["j" + std::to_string(i)];
        start_new_job = false;
        // run the job
        if (job["done"] == false) {
            if (job["num_runs"] == 0) {
                t = time(0);
                strftime(time_buffer, 80, "%Y%m%d_%H%M%S", localtime(&t));
                // generate name for the result dir
                std::string result_dir = Result_Output_Dir + "/";
                if (!group_name.empty())
                    result_dir += group_name + "_";
                if (job["nickname"] != "") {
                    result_dir += job["nickname"].get<std::string>() + "_";
                } else {
                    std::string env_name_converted(job["env"]);
                    std::replace(env_name_converted.begin(), env_name_converted.end(), '.', '_');
                    result_dir += env_name_converted + "_";
                }
                result_dir += time_buffer;
                job["result_dir"] = result_dir;

                // create and copy necessary files to the result dir
                // we are copying those files at the beginning (instead of the end)
                // so that partial results could be useful with all those info
                std::filesystem::create_directories(result_dir);
                if (job["nickname"] != "") {
                    ofs.open(result_dir + "/name.txt");
                    ofs << job["nickname"].get<std::string>();
                    ofs.close();
                }
                if (jsobj["group_comments"] != "") {
                    ofs.open(result_dir + "/group_comment.txt");
                    ofs << jsobj["group_comments"].get<std::string>();
                    ofs.close();
                }
                if (job["comments"] != "") {
                    ofs.open(result_dir + "/job_comment.txt");
                    ofs << job["comments"].get<std::string>();
                    ofs.close();
                }

                job["start_time"] = time_buffer;
                start_new_job = true;
            }

            job["num_runs"] = job["num_runs"].get<int>() + 1;
            ofs.open(jobfile_fullpath);
            ofs << jsobj.dump(2) << std::endl; // the number in json::dump specifies indention
            ofs.close();

            if (start_new_job) {
                EvoGenTrainingConfigs training_configs;
                training_configs.set_num_gen(job["num_gen"]);
                training_configs.set_pop_size(job["pop_size"]);
                training_configs.set_env(job["env"]);
                training_configs.set_sim_time(job["sim_time"]);
                training_configs.set_output_dir(job["result_dir"]);
                std::string bagfile_basename = job["bagfile"];
                if (bagfile_basename != "") {
                    bagfile_basename.erase(bagfile_basename.find(".json"), 5);
                }

                std::cout << "Launching new job " << job["result_dir"] << std::endl;
                new_training_from_job(training_configs, bagfile_basename);
            } else {
                std::cout << "Resuming job " << job["result_dir"] << std::endl;
                resume_from_job(job["result_dir"]);
            }

            // if returned from training, update group_status and write to file
            t = time(0);
            strftime(time_buffer, 80, "%Y%m%d_%H%M%S", localtime(&t));
            job["finish_time"] = time_buffer;

            ofs.open(job["result_dir"].get<std::string>() + "/job_report.txt");
            ofs << "job schedule time: " << jsobj["timestamp"].get<std::string>() << std::endl
                << "job start time: " << job["start_time"].get<std::string>() << std::endl
                << "job finish time: " << job["finish_time"].get<std::string>() << std::endl
                << "total number of runs: " << job["num_runs"] << std::endl;
            ofs.close();

            job["done"] = true;
        }

        jsobj["current_job"] = i + 1;
        ofs.open(jobfile_fullpath);
        ofs << jsobj.dump(2) << std::endl; // the number in json::dump specifies indention
        ofs.close();
    }

    std::cout << "All jobs in job file done, exit" << std::endl;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        const auto& exe_name = std::filesystem::path(std::string(argv[0])).filename().string();
        std::cout << "Usage:"  << std::endl;
        std::cout << "    1) To start new training with random seeds: " << exe_name << " new"  << std::endl;
        std::cout << "    2) To start new training with user seeds: " << exe_name << " new user <bag_file_basename>"  << std::endl;
        std::cout << "    3) To resume an existing training: " << exe_name << " resume <result_dir_basename>"  << std::endl;
        std::cout << "    4) To load a job file: " << exe_name << " job <job_file_basename>"  << std::endl;
        return 0;
    }
    std::string mode(argv[1]);
    if (mode == "new") {
        new_training_from_cmd(argc > 2 && std::string(argv[2]) == "user" ? std::string(argv[3]) : std::string());
    } else if (mode == "resume") {
        resume_training(std::string(argv[2]));
    } else if (mode == "job") {
        process_job_file(std::string(argv[2]));
    } else {
        std::cout << "Error: wrong mode " << mode << std::endl;
    }
    return 0;
}
