#include <filesystem>

#include "SimulatorParams.h"
#include "EvoParams.h"
#include "EvoGenerator.h"

#include "evo_paths.h"

int main(int argc, char **argv)
{
    EvoGenerator evo_gen;
    EvoParams evo_params;
    SimulatorParams sim_params;
    evo_params.set_nb_gen(200);

    // if (argc == 2) {
        // std::filesystem::path res_path(argv[1]);
        // sim_params.Load(res_path.parent_path().parent_path().string() + "/sim_params.xml");
        // EvoGenerator evo_gen;
        // evo_gen.resume(res_path.string());
        // std::cout << "Done" << std::endl;
        // return 0;
    // }

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

    // sim_params needs to be set before the creation of EA instance
    sim_params.SetEnv(Resource_Map_Dir + "/env3.bmp");
    // sim_params.do_viz = true;
    // sim_params.do_realtime = true;
    sim_params.AddWaypoint(0.5, 1.5, 0.3);
    sim_params.SetCamera(2.5, -1, 3, 2.5, 1.5, 0);

    evo_gen.set_evo_params(evo_params);
    evo_gen.set_sim_params(sim_params);
    evo_gen.set_result_dir(log_dir);

    evo_gen.run();

    return 0;
}
