#include "GenerateDemoRobot.h"

#include <map>
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#include <filesystem>

#include "evo_paths.h"

std::string generate_demo_robot_string(std::string mode, const std::vector<float>& scales) {

    std::ostringstream oss;

    oss << "<?xml verison=\"1.0\"?>" << std::endl;
    oss << "<robot name =\"temp_robot\">" << std::endl;
    oss << std::endl;

    // chassis
    oss << "<link name = \"chassis\">" << std::endl;
    oss << " <visual>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    oss << "    <box size=\"" << 0.3 * scales[0] << " " << 0.2 * scales[1] << " " << 0.05 * scales[2] << "\"/>" << std::endl;
    oss << "  </geometry>" << std::endl;
    oss << " </visual>" << std::endl;
    oss << " <collision>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    oss << "    <box size=\"" << 0.3 * scales[0] << " " << 0.2 * scales[1] << " " << 0.05 * scales[2] << "\"/>" << std::endl;
    oss << "  </geometry>" << std::endl;
    oss << " </collision>" << std::endl;
    oss << " <inertial>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <mass value = \"" << "1" << "\" />" << std::endl;
    oss << "  <inertia ixx = \"" << "1" << "\" ixy = \"" << "0" << "\" ixz = \"" << "0" << "\" iyy = \"" << "1" << "\" iyz = \"" << "0" << "\" izz = \"" << "1" << "\" />" << std::endl;
    oss << " </inertial>" << std::endl;
    oss << "</link>" << std::endl;
    oss << std::endl;

    // wheel_fl
    oss << "<link name = \"wheel_fl\">" << std::endl;
    oss << " <visual>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    if (mode == "wheel")
        oss << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * scales[3] << "\"/>" << std::endl;
    else if (mode == "leg")
        oss << "    <box size=\"0.015 " << 0.085 * scales[3] << " 0.015\"/>" << std::endl;
    oss << "  </geometry>" << std::endl;
    oss << " </visual>" << std::endl;
    oss << " <collision>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    if (mode == "wheel")
        oss << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * scales[3] << "\"/>" << std::endl;
    else if (mode == "leg")
        oss << "    <box size=\"0.015 " << 0.085 * scales[3] << " 0.015\"/>" << std::endl;
    oss << "  </geometry>" << std::endl;
    oss << " </collision>" << std::endl;
    oss << " <inertial>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <mass value = \"" << "1" << "\" />" << std::endl;
    oss << "  <inertia ixx = \"" << "1" << "\" ixy = \"" << "0" << "\" ixz = \"" << "0" << "\" iyy = \"" << "1" << "\" iyz = \"" << "0" << "\" izz = \"" << "1" << "\" />" << std::endl;
    oss << " </inertial>" << std::endl;
    oss << "</link>" << std::endl;
    oss << std::endl;

    // wheel_fr
    oss << "<link name = \"wheel_fr\">" << std::endl;
    oss << " <visual>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    if (mode == "wheel")
        oss << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * scales[4] << "\"/>" << std::endl;
    else if (mode == "leg")
        oss << "    <box size=\"0.015 " << 0.085 * scales[4] << " 0.015\"/>" << std::endl;
    oss << "  </geometry>" << std::endl;
    oss << " </visual>" << std::endl;
    oss << " <collision>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    if (mode == "wheel")
        oss << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * scales[4] << "\"/>" << std::endl;
    else if (mode == "leg")
        oss << "    <box size=\"0.015 " << 0.085 * scales[4] << " 0.015\"/>" << std::endl;
    oss << "  </geometry>" << std::endl;
    oss << " </collision>" << std::endl;
    oss << " <inertial>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <mass value = \"" << "1" << "\" />" << std::endl;
    oss << "  <inertia ixx = \"" << "1" << "\" ixy = \"" << "0" << "\" ixz = \"" << "0" << "\" iyy = \"" << "1" << "\" iyz = \"" << "0" << "\" izz = \"" << "1" << "\" />" << std::endl;
    oss << " </inertial>" << std::endl;
    oss << "</link>" << std::endl;
    oss << std::endl;

    // wheel_rl
    oss << "<link name = \"wheel_rl\">" << std::endl;
    oss << " <visual>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    if (mode == "wheel")
        oss << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * scales[5] << "\"/>" << std::endl;
    else if (mode == "leg")
        oss << "    <box size=\"0.015 " << 0.085 * scales[5] << " 0.015\"/>" << std::endl;
    oss << "  </geometry>" << std::endl;
    oss << " </visual>" << std::endl;
    oss << " <collision>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    if (mode == "wheel")
        oss << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * scales[5] << "\"/>" << std::endl;
    else if (mode == "leg")
        oss << "    <box size=\"0.015 " << 0.085 * scales[5] << " 0.015\"/>" << std::endl;
    oss << "  </geometry>" << std::endl;
    oss << " </collision>" << std::endl;
    oss << " <inertial>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <mass value = \"" << "1" << "\" />" << std::endl;
    oss << "  <inertia ixx = \"" << "1" << "\" ixy = \"" << "0" << "\" ixz = \"" << "0" << "\" iyy = \"" << "1" << "\" iyz = \"" << "0" << "\" izz = \"" << "1" << "\" />" << std::endl;
    oss << " </inertial>" << std::endl;
    oss << "</link>" << std::endl;
    oss << std::endl;

    // wheel_rr
    oss << "<link name = \"wheel_rr\">" << std::endl;
    oss << " <visual>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    if (mode == "wheel")
        oss << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * scales[6] << "\"/>" << std::endl;
    else if (mode == "leg")
        oss << "    <box size=\"0.015 " << 0.085 * scales[6] << " 0.015\"/>" << std::endl;
    oss << "  </geometry>" << std::endl;
    oss << " </visual>" << std::endl;
    oss << " <collision>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    if (mode == "wheel")
        oss << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * scales[6] << "\"/>" << std::endl;
    else if (mode == "leg")
        oss << "    <box size=\"0.015 " << 0.085 * scales[6] << " 0.015\"/>" << std::endl;
    oss << "  </geometry>" << std::endl;
    oss << " </collision>" << std::endl;
    oss << " <inertial>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <mass value = \"" << "1" << "\" />" << std::endl;
    oss << "  <inertia ixx = \"" << "1" << "\" ixy = \"" << "0" << "\" ixz = \"" << "0" << "\" iyy = \"" << "1" << "\" iyz = \"" << "0" << "\" izz = \"" << "1" << "\" />" << std::endl;
    oss << " </inertial>" << std::endl;
    oss << "</link>" << std::endl;
    oss << std::endl;

    // chassis_wheel_fr
    oss << "<joint name = \"chassis_wheel_fr\" type = \"continuous\">" << std::endl;
    oss << "  <parent link = \"chassis\"/>" << std::endl;
    oss << "  <child link = \"wheel_fr\"/>" << std::endl;
    oss << "   <origin xyz = \"" << 0.3 * scales[0] / 3 << " " << -1 * (0.2 * scales[1] / 2 + 0.05) << " 0 \" rpy = \"1.57 0 0\" />" << std::endl;
    oss << "   <axis xyz = \"0 0 1\" />" << std::endl;
    oss << "</joint>" << std::endl;
    oss << std::endl;

    // chassis_wheel_fl
    oss << "<joint name = \"chassis_wheel_fl\" type = \"continuous\">" << std::endl;
    oss << "  <parent link = \"chassis\"/>" << std::endl;
    oss << "  <child link = \"wheel_fl\"/>" << std::endl;
    oss << "   <origin xyz = \"" << 0.3 * scales[0] / 3 << " " << 0.2 * scales[1] / 2 + 0.05 << " 0 \" rpy = \"1.57 0 0\" />" << std::endl;
    oss << "   <axis xyz = \"0 0 1\" />" << std::endl;
    oss << "</joint>" << std::endl;
    oss << std::endl;

    // chassis_wheel_rr
    oss << "<joint name = \"chassis_wheel_rr\" type = \"continuous\">" << std::endl;
    oss << "  <parent link = \"chassis\"/>" << std::endl;
    oss << "  <child link = \"wheel_rr\"/>" << std::endl;
    oss << "   <origin xyz = \"" << -0.3 * scales[0] / 3 << " " << -1 * (0.2 * scales[1] / 2 + 0.05) << " 0 \" rpy = \"1.57 0 0\" />" << std::endl;
    oss << "   <axis xyz = \"0 0 1\" />" << std::endl;
    oss << "</joint>" << std::endl;
    oss << std::endl;

    // chassis_wheel_rl
    oss << "<joint name = \"chassis_wheel_rl\" type = \"continuous\">" << std::endl;
    oss << "  <parent link = \"chassis\"/>" << std::endl;
    oss << "  <child link = \"wheel_rl\"/>" << std::endl;
    oss << "   <origin xyz = \"" << -0.3 * scales[0] / 3 << " " << 0.2 * scales[1] / 2 + 0.05 << " 0 \" rpy = \"1.57 0 0\" />" << std::endl;
    oss << "   <axis xyz = \"0 0 1\" />" << std::endl;
    oss << "</joint>" << std::endl;
    oss << std::endl;

    oss << "</robot>" << std::endl;

    return oss.str();
}

void generate_demo_robot(std::string mode, const std::vector<float>& scales) {
    std::string output_file(Robot_Output_Dir + "/temp_robot/" + "temp_robot.urdf");

    std::filesystem::path output_path(output_file);
    output_path.remove_filename();
    if (!std::filesystem::exists(output_path))
        std::filesystem::create_directory(output_path);

    std::ofstream ofs(output_file.c_str(), std::ostream::out);
    ofs << generate_demo_robot_string(mode, scales);
    ofs.close();
}

