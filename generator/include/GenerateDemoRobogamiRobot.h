#ifndef EVOGEN_GENERATOR_GENERATEDEMOROBOGAMIROBOT_H_
#define EVOGEN_GENERATOR_GENERATEDEMOROBOGAMIROBOT_H_

#include <string>
#include <vector>
#include "RobotRepresentation.h"

void init_robogami_library();
void set_mesh_dir(const std::string& new_root);
void generate_demo_robogami_robot_file(const std::string& mode,
                                       const RobotRepresentation& robot,
                                       const std::string& robot_name="temp_robot");
void generate_demo_robogami_robot_file(const std::string& mode,
                                       const std::vector<double>& design_vector,
                                       const std::string& robot_name="temp_robot");
std::string generate_demo_robogami_robot_string(const std::string& mode,
                                                const RobotRepresentation& robot,
                                                const std::string& robot_name="temp_robot");
std::string generate_demo_robogami_robot_string(const std::string& mode,
                                                const std::vector<double>& design_vector,
                                                const std::string& robot_name="temp_robot");

#endif /* end of include guard: EVOGEN_GENERATOR_GENERATEDEMOROBOGAMIROBOT_H_ */
