#include <iostream>
#include <string>

#include "SimulationManager.h"
#include "evo_paths.h"

const double s_friction = 2.0;
const double k_friction = 1.9;

void load_robot(std::string robot_name){
    const std::string urdf_filename = Robot_Output_Dir + "/" + robot_name + "/" + robot_name + ".urdf";

    SimulationManager sm;
    sm.SetUrdfFile(urdf_filename);
    // sm.SetEnv(env_filename, 50, 50, 0.5);
    // sm.DisableEnv();
    sm.SetFrictionK(k_friction);
    sm.SetFrictionS(s_friction);
    sm.SetTimeout(5000);

    sm.AddWaypoint(0, 0, 2);

    sm.RunSimulation();
}

int main(int argc, char* argv[]) {
    load_robot("killer");
    return EXIT_SUCCESS;
}
