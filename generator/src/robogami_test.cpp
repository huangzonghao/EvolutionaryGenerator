#include <iostream>

// #include "UrdfExporter.h"
#include "GenerateDemoRobot.h"

#include "evo_paths.h"
// #include "robogami_paths.h"

int main(int argc, char *argv[]) {
    // protoToUrdf(Robogami_Data_Dir + "/proto/examples/killerBasket_good_servospacing.asciiproto", "killer");
    std::vector<double> design_vector = {4, 1, 1, 1, 0.625, 1, 0.875, 1, 1.125, 1, 1.375, 1}; // default robot
    // std::vector<double> design_vector = {4, 1, 1, 1, 0.7, 1, 1.2, 1, 1.1, 1, 0.6, 1};
    generate_demo_robot_file("leg", design_vector, "test_1");
    std::cout << "robogami test done" << std::endl;
    system("pause");
}
