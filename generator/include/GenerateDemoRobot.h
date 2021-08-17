#ifndef EVOGEN_GENERATOR_GENERATEDEMOROBOT_H_
#define EVOGEN_GENERATOR_GENERATEDEMOROBOT_H_

#include <string>
#include <vector>

// TODO: why not double?
void generate_demo_robot_file(const std::string& mode,
                              const std::vector<double>& design_vector,
                              const std::string& robot_name="temp_robot");
std::string generate_demo_robot_string(const std::string& mode,
                                       const std::vector<double>& design_vector,
                                       const std::string& robot_name="temp_robot");

#endif /* end of include guard: EVOGEN_GENERATOR_GENERATEDEMOROBOT_H_ */
