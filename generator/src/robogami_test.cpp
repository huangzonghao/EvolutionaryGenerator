#include <iostream>

// #include "UrdfExporter.h"
#include "GenerateDemoRobot.h"

#include "evo_paths.h"
// #include "robogami_paths.h"

int main(int argc, char *argv[]) {
    // protoToUrdf(Robogami_Data_Dir + "/proto/examples/killerBasket_good_servospacing.asciiproto", "killer");
    std::vector<double> design_vector = {1, 1, 1, 4, 0.125, 1, 0.1, 1, 0.375, 1,  0.1, 1, 0.625, 1, 0.1, 1, 0.875, 1, 0.1, 1}; // default robot
    // std::vector<double> design_vector = {1, 1, 1, 4, 0.125, 2, 0.1, 1, 0.4, 1, 0.375, 1,  0.1, 1, 0.625, 1, 0.1, 1, 0.875, 3, 0.1, 1, 0.1, 1, 0.1, 1}; // multi-link test
    generate_demo_robot_file("leg", design_vector, "test_1");
    std::cout << "robogami test done" << std::endl;
    system("pause");
}
