#include "GenerateDemoRobot.h"

#include <map>
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#include <filesystem>

#include "evo_paths.h"

// remember to update these when updating evo side
constexpr size_t leg_offset = 4;
constexpr double phen_min = 0.5;
constexpr double phen_max = 1.5;

// design vector format: [num_legs, body_x, body_y, body_z, leg1_pos, leg1_len, ..., legN_pos, legN_len]
std::string generate_demo_robot_string(const std::string& mode,
                                       const std::vector<double>& dv,
                                       const std::string& robot_name) {
    std::ostringstream oss;

    oss << "<?xml verison=\"1.0\"?>" << std::endl;
    oss << "<robot name =\"" << robot_name << "\">" << std::endl;
    oss << std::endl;

    // chassis
    oss << "<link name = \"chassis\">" << std::endl;
    oss << " <visual>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    oss << "    <box size=\"" << 0.3 * dv[1] << " " << 0.2 * dv[2] << " " << 0.05 * dv[3] << "\"/>" << std::endl;
    oss << "  </geometry>" << std::endl;
    oss << " </visual>" << std::endl;
    oss << " <collision>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    oss << "    <box size=\"" << 0.3 * dv[1] << " " << 0.2 * dv[2] << " " << 0.05 * dv[3] << "\"/>" << std::endl;
    oss << "  </geometry>" << std::endl;
    oss << " </collision>" << std::endl;
    oss << " <inertial>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <mass value = \"" << "1" << "\" />" << std::endl;
    oss << "  <inertia ixx = \"" << "1" << "\" ixy = \"" << "0" << "\" ixz = \"" << "0" << "\" iyy = \"" << "1" << "\" iyz = \"" << "0" << "\" izz = \"" << "1" << "\" />" << std::endl;
    oss << " </inertial>" << std::endl;
    oss << "</link>" << std::endl;
    oss << std::endl;

    // add legs
    double pos_tmp;
    double pos_x_tmp;
    double pos_y_tmp;
    for (int i = 0; i < dv[0]; ++i) {
        // link
        oss << "<link name = \"leg_" << i << "\">" << std::endl;
        oss << " <visual>" << std::endl;
        oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
        oss << "  <geometry>" << std::endl;
        if (mode == "wheel")
            oss << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * dv[2*i+leg_offset+1] << "\"/>" << std::endl;
        else if (mode == "leg")
            oss << "    <box size=\"0.015 " << 0.085 * dv[2*i+leg_offset+1] << " 0.015\"/>" << std::endl;
        oss << "  </geometry>" << std::endl;
        oss << " </visual>" << std::endl;
        oss << " <collision>" << std::endl;
        oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
        oss << "  <geometry>" << std::endl;
        if (mode == "wheel")
            oss << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * dv[2*i+leg_offset+1] << "\"/>" << std::endl;
        else if (mode == "leg")
            oss << "    <box size=\"0.015 " << 0.085 * dv[2*i+leg_offset+1] << " 0.015\"/>" << std::endl;
        oss << "  </geometry>" << std::endl;
        oss << " </collision>" << std::endl;
        oss << " <inertial>" << std::endl;
        oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
        oss << "  <mass value = \"" << "1" << "\" />" << std::endl;
        oss << "  <inertia ixx = \"" << "1" << "\" ixy = \"" << "0" << "\" ixz = \"" << "0" << "\" iyy = \"" << "1" << "\" iyz = \"" << "0" << "\" izz = \"" << "1" << "\" />" << std::endl;
        oss << " </inertial>" << std::endl;
        oss << "</link>" << std::endl;
        oss << std::endl;

        // joint
        oss << "<joint name = \"chassis_leg_" << i << "\" type = \"continuous\">" << std::endl;
        oss << "  <parent link = \"chassis\"/>" << std::endl;
        oss << "  <child link = \"leg_" << i << "\"/>" << std::endl;

        pos_tmp = (dv[2*i+leg_offset] - phen_min) / (phen_max - phen_min);
        if (pos_tmp < 0.5) {
            pos_x_tmp = (0.25 - pos_tmp) * 4 * (0.3 * dv[1] / 2);
            pos_y_tmp = 0.2 * dv[2] / 2 + 0.05;
        } else {
            pos_x_tmp = (pos_tmp - 0.75) * 4 * (0.3 * dv[1] / 2);
            pos_y_tmp = -(0.2 * dv[2] / 2 + 0.05);
        }

        oss << "   <origin xyz = \"" << pos_x_tmp << " " << pos_y_tmp << " 0 \" rpy = \"1.57 0 0\" />" << std::endl;
        oss << "   <axis xyz = \"0 0 1\" />" << std::endl;
        oss << "</joint>" << std::endl;
        oss << std::endl;
    }

    oss << "</robot>" << std::endl;

    return oss.str();
}

void generate_demo_robot_file(const std::string& mode,
                              const std::vector<double>& dv,
                              const std::string& robot_name) {
    std::string output_file(Robot_Output_Dir + "/" + robot_name + "/" + robot_name + ".urdf");

    std::filesystem::path output_path(output_file);
    output_path.remove_filename();
    if (!std::filesystem::exists(output_path))
        std::filesystem::create_directory(output_path);

    std::ofstream ofs(output_file.c_str(), std::ostream::out);
    ofs << generate_demo_robot_string(mode, dv, robot_name);
    ofs.close();
}

