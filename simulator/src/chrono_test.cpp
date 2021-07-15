#include <iostream>
#include <string>

#include "SimulationManager.h"
#include "evo_paths.h"
#include "robogami_paths.h"

const double s_friction = 2.0;
const double k_friction = 1.9;

void load_robot(const std::string& robot_name){
    const std::string urdf_filename = Robot_Output_Dir + "/" + robot_name + "/" + robot_name + ".urdf";

    SimulationManager sm;
    sm.LoadUrdfFile(urdf_filename);
    sm.SetFrictionK(k_friction);
    sm.SetFrictionS(s_friction);
    sm.SetTimeout(15);

    sm.AddMotor("MOTOR", "chassis", "chassis_wheel_fl", 1,0.1,0.1,0.1);
    sm.AddMotor("MOTOR", "chassis", "chassis_wheel_rl", 1,0.1,0.1,0.1);
    sm.AddMotor("MOTOR", "chassis", "chassis_wheel_fr", 1,0.1,0.1,0.1);
    sm.AddMotor("MOTOR", "chassis", "chassis_wheel_rr", 1,0.1,0.1,0.1);
    sm.SetController(SimulationManager::ControllerType::Wheel);
    sm.SetEnv("ground", 10, 5, 0.01);
    sm.AddWaypoint(5, 2.5, 0.3);
    sm.SetCamera(5, 0, 3, 5, 2.5, 0);

    sm.RunSimulation();

    std::cout << "Root displacement: " << sm.GetRootBodyDisplacementX() << std::endl;
}

void load_robogami_robot(const std::string& robot_name) {
    const std::string proto_filename = Robogami_Data_Dir + "/proto/examples/" + robot_name + ".asciiproto";

    SimulationManager sm;
    sm.SetController(SimulationManager::ControllerType::Dummy);
    sm.LoadRobogamiProtoFile(proto_filename);
    sm.DisableEnv();
    sm.AddWaypoint(0, 0, 0);
    // sm.SetCamera(0, 200, -50, 0, 0, 0);
    sm.SetTimeout(500);
    sm.RunSimulation();

}

int main(int argc, char* argv[]) {
    // load_robot("fourwheels");
    load_robogami_robot("killerBasket_good_servospacing");

    return EXIT_SUCCESS;
}
