#include <iostream>
#include <string>

#include "SimulationManager.h"
#include "UrdfExporter.h"

#include "evo_paths.h"
#include "robogami_paths.h"

const double s_friction = 2.0;
const double k_friction = 1.9;

void generate_robot() {

}

void export_robot() {
    protoToUrdf(Robogami_Data_Dir + "/proto/examples/killerBasket_good_servospacing.asciiproto", "killer");
}

void load_robot(std::string robot_name){
    const std::string urdf_filename = Robot_Output_Dir + "/" + robot_name + "/" + robot_name + ".urdf";

    SimulationManager sm;
    sm.SetUrdfFile(urdf_filename);
    // sm.SetEnv(env_filename, 50, 50, 0.5);
    // sm.DisableEnv();
    sm.SetFrictionK(k_friction);
    sm.SetFrictionS(s_friction);
    sm.SetTimeout(5000);

    sm.AddMotor("MOTOR", "chassis_wheel_fl", 1,0.1,0.1,0.1);
    sm.AddMotor("MOTOR", "chassis_wheel_rl", 1,0.1,0.1,0.1);
    sm.AddMotor("MOTOR", "chassis_wheel_fr", 1,0.1,0.1,0.1);
    sm.AddMotor("MOTOR", "chassis_wheel_rr", 1,0.1,0.1,0.1);

    sm.AddWaypoint(0.5, 0.5, 0.3);
    sm.AddWaypoint(0.5, 0.8, 0.3);

    sm.RunSimulation(true, true);
}

int main(int argc, char* argv[]) {
    export_robot();
    load_robot("fourwheels");
    return EXIT_SUCCESS;
}
