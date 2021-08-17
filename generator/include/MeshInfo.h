#ifndef EVOGEN_GENERATOR_MESHINFO_H_
#define EVOGEN_GENERATOR_MESHINFO_H_

#include <array>
#include <vector>
#include <string>

#include "evo_paths.h"

class MeshInfo {
  public:
    std::string body_mesh_dir = Robot_Parts_Dir + "/bodies";
    std::string leg_mesh_dir = Robot_Parts_Dir + "/legs";
    const int num_bodies = 5;
    const int num_legs = 11;
    const double scale_x = 0.01;
    const double scale_y = 0.01;
    const double scale_z = 0.01;

    MeshInfo();
    void print_all_size();
    double get_body_size(int body_id, int dim) const;
    double get_leg_size(int leg_id, int dim) const;
    double get_leg_length(int leg_id) const;
    void set_mesh_dir(const std::string& new_root);
  private:
    void load_info();
    std::vector<std::array<double, 3>> body_size;
    std::vector<std::array<double, 3>> leg_size;
};

#endif /* end of include guard: EVOGEN_GENERATOR_MESHINFO_H_ */
