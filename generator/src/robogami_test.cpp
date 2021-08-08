#include <iostream>

// #include "UrdfExporter.h"
#include "GenerateDemoRobot.h"
#include "GenerateDemoRobogamiRobot.h"

#include "evo_paths.h"
// #include "robogami_paths.h"

int main(int argc, char *argv[]) {
    // protoToUrdf(Robogami_Data_Dir + "/proto/examples/killerBasket_good_servospacing.asciiproto", "killer");
    // Note: body_id and leg_ids are [0, 1];
    // std::vector<double> design_vector = {0.1, 1, 1, 1, // body_id, scale_x, scale_y, scale_z
                                         // 4,            // num_legs
                                         // 0.125, 1, 0.1, 2,
                                         // 0.375, 1, 0.1, 1,
                                         // 0.625, 1, 0.1, 1,
                                         // 0.875, 1, 0.1, 1};
    std::vector<double> design_vector = {0.1, 1, 1, 1, // body_id, scale_x, scale_y, scale_z
                                         4,            // num_legs
                                         0.125, 3, 0.1, 1.5, 0.5, 1, 0.75, 0.5,
                                         0.375, 1, 0.1, 1,
                                         0.625, 1, 0.1, 1,
                                         0.875, 1, 0.1, 1};
    // std::vector<double> design_vector = {1, 1, 1, 4, 0.125, 2, 0.1, 1, 0.4, 1, 0.375, 1,  0.1, 1, 0.625, 1, 0.1, 1, 0.875, 3, 0.1, 1, 0.1, 1, 0.1, 1}; // multi-link test
    generate_demo_robogami_robot_file("leg", design_vector, "test_1");
    std::cout << "robogami test done" << std::endl;
}
