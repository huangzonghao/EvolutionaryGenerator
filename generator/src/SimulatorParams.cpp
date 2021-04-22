#include "SimulatorParams.h"

#include "evo_paths.h"

void SimulatorParams::SetEnv(const std::string& new_env) {
        env_name = Resource_Map_Dir + "/" + new_env;
}

void SimulatorParams::AddWaypoint(double x, double y, double z) {
    waypoints_.push_back(std::vector<double>{x,y,z});
}

