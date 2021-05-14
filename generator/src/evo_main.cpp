#include <filesystem>

#include "SimulatorParams.h"
#include "EvoParams.h"
#include "EvoGenerator.h"

#include "evo_paths.h"

int main(int argc, char **argv)
{
    EvoGenerator evo_gen;

    if (argc == 2) {
        evo_gen.resume(std::string(argv[1]));
        return 0;
    }

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
        std::cout << "Edit those files and relaurch" << std::endl;
        return 0;
    }

    // set up output dir
    time_t t = time(0);
    char time_buffer [80];
    strftime(time_buffer, 80, "%Y%m%d_%H%M%S", localtime(&t));

    std::string log_dir = Result_Output_Dir + "/EvoGen_" +
                          "P" + std::to_string(evo_params.pop_size()) +
                          "G" + std::to_string(evo_params.nb_gen()) + "_" +
                          std::to_string(evo_params.grid_shape()[0]) + "x" +
                          std::to_string(evo_params.grid_shape()[1]) +
                          "_" + time_buffer;

    evo_gen.set_evo_params(evo_params);
    evo_gen.set_sim_params(sim_params);
    evo_gen.set_result_dir(log_dir);

    evo_gen.run();

    return 0;
}
