#include "GenerateDemoRobot.h"

#include <map>
#include <fstream>
#include <filesystem>

#include "evo_paths.h"

void generate_demo_robot(std::string mode, double scales[7]) {

    std::string output_file(Robot_Output_Dir + "/temp_robot/" + "temp_robot.urdf");

    std::filesystem::path output_path(output_file);
    output_path.remove_filename();
    if (!std::filesystem::exists(output_path))
        std::filesystem::create_directory(output_path);

    std::ofstream ofs(output_file.c_str(), std::ofstream::out);

    ofs << "<?xml verison=\"1.0\"?>" << std::endl;
    ofs << "<robot name =\"temp_robot\">" << std::endl;
    ofs << std::endl;

    // chassis
    ofs << "<link name = \"chassis\">" << std::endl;
    ofs << " <visual>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <geometry>" << std::endl;
    ofs << "    <box size=\"" << 0.3 * scales[0] << " " << 0.2 * scales[1] << " " << 0.05 * scales[2] << "\"/>" << std::endl;
    ofs << "  </geometry>" << std::endl;
    ofs << " </visual>" << std::endl;
    ofs << " <collision>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <geometry>" << std::endl;
    ofs << "    <box size=\"" << 0.3 * scales[0] << " " << 0.2 * scales[1] << " " << 0.05 * scales[2] << "\"/>" << std::endl;
    ofs << "  </geometry>" << std::endl;
    ofs << " </collision>" << std::endl;
    ofs << " <inertial>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <mass value = \"" << "1" << "\" />" << std::endl;
    ofs << "  <inertia ixx = \"" << "1" << "\" ixy = \"" << "0" << "\" ixz = \"" << "0" << "\" iyy = \"" << "1" << "\" iyz = \"" << "0" << "\" izz = \"" << "1" << "\" />" << std::endl;
    ofs << " </inertial>" << std::endl;
    ofs << "</link>" << std::endl;
    ofs << std::endl;

    // wheel_fl
    ofs << "<link name = \"wheel_fl\">" << std::endl;
    ofs << " <visual>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <geometry>" << std::endl;
    if (mode == "wheel")
        ofs << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * scales[3] << "\"/>" << std::endl;
    else if (mode == "leg")
        ofs << "    <box size=\"0.015 " << 0.085 * scales[3] << " 0.015\"/>" << std::endl;
    ofs << "  </geometry>" << std::endl;
    ofs << " </visual>" << std::endl;
    ofs << " <collision>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <geometry>" << std::endl;
    if (mode == "wheel")
        ofs << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * scales[3] << "\"/>" << std::endl;
    else if (mode == "leg")
        ofs << "    <box size=\"0.015 " << 0.085 * scales[3] << " 0.015\"/>" << std::endl;
    ofs << "  </geometry>" << std::endl;
    ofs << " </collision>" << std::endl;
    ofs << " <inertial>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <mass value = \"" << "1" << "\" />" << std::endl;
    ofs << "  <inertia ixx = \"" << "1" << "\" ixy = \"" << "0" << "\" ixz = \"" << "0" << "\" iyy = \"" << "1" << "\" iyz = \"" << "0" << "\" izz = \"" << "1" << "\" />" << std::endl;
    ofs << " </inertial>" << std::endl;
    ofs << "</link>" << std::endl;
    ofs << std::endl;

    // wheel_fr
    ofs << "<link name = \"wheel_fr\">" << std::endl;
    ofs << " <visual>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <geometry>" << std::endl;
    if (mode == "wheel")
        ofs << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * scales[4] << "\"/>" << std::endl;
    else if (mode == "leg")
        ofs << "    <box size=\"0.015 " << 0.085 * scales[4] << " 0.015\"/>" << std::endl;
    ofs << "  </geometry>" << std::endl;
    ofs << " </visual>" << std::endl;
    ofs << " <collision>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <geometry>" << std::endl;
    if (mode == "wheel")
        ofs << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * scales[4] << "\"/>" << std::endl;
    else if (mode == "leg")
        ofs << "    <box size=\"0.015 " << 0.085 * scales[4] << " 0.015\"/>" << std::endl;
    ofs << "  </geometry>" << std::endl;
    ofs << " </collision>" << std::endl;
    ofs << " <inertial>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <mass value = \"" << "1" << "\" />" << std::endl;
    ofs << "  <inertia ixx = \"" << "1" << "\" ixy = \"" << "0" << "\" ixz = \"" << "0" << "\" iyy = \"" << "1" << "\" iyz = \"" << "0" << "\" izz = \"" << "1" << "\" />" << std::endl;
    ofs << " </inertial>" << std::endl;
    ofs << "</link>" << std::endl;
    ofs << std::endl;

    // wheel_rl
    ofs << "<link name = \"wheel_rl\">" << std::endl;
    ofs << " <visual>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <geometry>" << std::endl;
    if (mode == "wheel")
        ofs << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * scales[5] << "\"/>" << std::endl;
    else if (mode == "leg")
        ofs << "    <box size=\"0.015 " << 0.085 * scales[5] << " 0.015\"/>" << std::endl;
    ofs << "  </geometry>" << std::endl;
    ofs << " </visual>" << std::endl;
    ofs << " <collision>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <geometry>" << std::endl;
    if (mode == "wheel")
        ofs << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * scales[5] << "\"/>" << std::endl;
    else if (mode == "leg")
        ofs << "    <box size=\"0.015 " << 0.085 * scales[5] << " 0.015\"/>" << std::endl;
    ofs << "  </geometry>" << std::endl;
    ofs << " </collision>" << std::endl;
    ofs << " <inertial>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <mass value = \"" << "1" << "\" />" << std::endl;
    ofs << "  <inertia ixx = \"" << "1" << "\" ixy = \"" << "0" << "\" ixz = \"" << "0" << "\" iyy = \"" << "1" << "\" iyz = \"" << "0" << "\" izz = \"" << "1" << "\" />" << std::endl;
    ofs << " </inertial>" << std::endl;
    ofs << "</link>" << std::endl;
    ofs << std::endl;

    // wheel_rr
    ofs << "<link name = \"wheel_rr\">" << std::endl;
    ofs << " <visual>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <geometry>" << std::endl;
    if (mode == "wheel")
        ofs << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * scales[6] << "\"/>" << std::endl;
    else if (mode == "leg")
        ofs << "    <box size=\"0.015 " << 0.085 * scales[6] << " 0.015\"/>" << std::endl;
    ofs << "  </geometry>" << std::endl;
    ofs << " </visual>" << std::endl;
    ofs << " <collision>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <geometry>" << std::endl;
    if (mode == "wheel")
        ofs << "    <cylinder length=\"" << 0.03 << "\" radius=\"" << 0.045 * scales[6] << "\"/>" << std::endl;
    else if (mode == "leg")
        ofs << "    <box size=\"0.015 " << 0.085 * scales[6] << " 0.015\"/>" << std::endl;
    ofs << "  </geometry>" << std::endl;
    ofs << " </collision>" << std::endl;
    ofs << " <inertial>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <mass value = \"" << "1" << "\" />" << std::endl;
    ofs << "  <inertia ixx = \"" << "1" << "\" ixy = \"" << "0" << "\" ixz = \"" << "0" << "\" iyy = \"" << "1" << "\" iyz = \"" << "0" << "\" izz = \"" << "1" << "\" />" << std::endl;
    ofs << " </inertial>" << std::endl;
    ofs << "</link>" << std::endl;
    ofs << std::endl;

    // chassis_wheel_fr
    ofs << "<joint name = \"chassis_wheel_fr\" type = \"continuous\">" << std::endl;
    ofs << "  <parent link = \"chassis\"/>" << std::endl;
    ofs << "  <child link = \"wheel_fr\"/>" << std::endl;
    ofs << "   <origin xyz = \"" << 0.3 * scales[0] / 3 << " " << -1 * (0.2 * scales[1] / 2 + 0.05) << " 0 \" rpy = \"1.57 0 0\" />" << std::endl;
    ofs << "   <axis xyz = \"0 0 1\" />" << std::endl;
    ofs << "</joint>" << std::endl;
    ofs << std::endl;

    // chassis_wheel_fl
    ofs << "<joint name = \"chassis_wheel_fl\" type = \"continuous\">" << std::endl;
    ofs << "  <parent link = \"chassis\"/>" << std::endl;
    ofs << "  <child link = \"wheel_fl\"/>" << std::endl;
    ofs << "   <origin xyz = \"" << 0.3 * scales[0] / 3 << " " << 0.2 * scales[1] / 2 + 0.05 << " 0 \" rpy = \"1.57 0 0\" />" << std::endl;
    ofs << "   <axis xyz = \"0 0 1\" />" << std::endl;
    ofs << "</joint>" << std::endl;
    ofs << std::endl;

    // chassis_wheel_rr
    ofs << "<joint name = \"chassis_wheel_rr\" type = \"continuous\">" << std::endl;
    ofs << "  <parent link = \"chassis\"/>" << std::endl;
    ofs << "  <child link = \"wheel_rr\"/>" << std::endl;
    ofs << "   <origin xyz = \"" << -0.3 * scales[0] / 3 << " " << -1 * (0.2 * scales[1] / 2 + 0.05) << " 0 \" rpy = \"1.57 0 0\" />" << std::endl;
    ofs << "   <axis xyz = \"0 0 1\" />" << std::endl;
    ofs << "</joint>" << std::endl;
    ofs << std::endl;

    // chassis_wheel_rl
    ofs << "<joint name = \"chassis_wheel_rl\" type = \"continuous\">" << std::endl;
    ofs << "  <parent link = \"chassis\"/>" << std::endl;
    ofs << "  <child link = \"wheel_rl\"/>" << std::endl;
    ofs << "   <origin xyz = \"" << -0.3 * scales[0] / 3 << " " << 0.2 * scales[1] / 2 + 0.05 << " 0 \" rpy = \"1.57 0 0\" />" << std::endl;
    ofs << "   <axis xyz = \"0 0 1\" />" << std::endl;
    ofs << "</joint>" << std::endl;
    ofs << std::endl;

    ofs << "</robot>" << std::endl;
    ofs.close();
}

