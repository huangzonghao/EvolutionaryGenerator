#ifndef EVOGEN_GENERATOR_INCLUDE_MESHINFO_H_
#define EVOGEN_GENERATOR_INCLUDE_MESHINFO_H_

#include <array>
#include <vector>
#include <string>

#include "evo_paths.h"

class MeshInfo {
  public:
    const std::string body_tmp_dir = Robot_Output_Dir + "/tmp_robot_parts/bodies";
    const std::string leg_tmp_dir = Robot_Output_Dir + "/tmp_robot_parts/legs";
    const int num_bodies = 5;
    const int num_legs = 11;
    const double scale_x = 0.01;
    const double scale_y = 0.01;
    const double scale_z = 0.01;

    MeshInfo();
    void print_all_size();
    double get_body_size(int body_id, int dim) const;
    double get_leg_size(int leg_id, int dim) const;
  private:
    std::vector<std::array<double, 3>> body_size;
    std::vector<std::array<double, 3>> leg_size;
};

#endif /* end of include guard: EVOGEN_GENERATOR_INCLUDE_MESHINFO_H_ */
