#ifndef GENERATEDEMOROBOT_H_HEJ0DKGV
#define GENERATEDEMOROBOT_H_HEJ0DKGV

#include <string>
#include <vector>

// TODO: why not double?
void generate_demo_robot_file(const std::string& mode,
                              const std::vector<double>& design_vector,
                              const std::string& robot_name="temp_robot");
std::string generate_demo_robot_string(const std::string& mode,
                                       const std::vector<double>& design_vector,
                                       const std::string& robot_name="temp_robot");

#endif /* end of include guard: GENERATEDEMOROBOT_H_HEJ0DKGV */
