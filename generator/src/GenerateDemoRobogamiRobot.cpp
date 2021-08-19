#include "GenerateDemoRobogamiRobot.h"

#include <map>
#include <string>
#include <fstream>
#include <sstream>
#include <filesystem>
// #include "RobogamiLibrary.h"
#include "MeshInfo.h"
#include "RobotRepresentation.h"
#include "robogami_paths.h"
#include "evo_paths.h"

extern MeshInfo mesh_info; // defined in MeshInfo.cpp
// constexpr double leg_length_ref = 0.085 * 1.2;

void init_robogami_library() {
    // RobogamiLibrary robogami_lib(Robogami_Data_Dir + "/proto");
    // robogami_lib.OutputMeshFiles(Robot_Parts_Dir);
}

std::string generate_demo_robogami_robot_string(const std::string& mode,
                                                const RobotRepresentation& robot,
                                                const std::string& robot_name) {

    const std::string mesh_ext = ".obj";
    std::ostringstream oss;

    oss << "<?xml verison=\"1.0\"?>" << std::endl;
    oss << "<robot name =\"" << robot_name << "\">" << std::endl;
    oss << std::endl;

    // chassis
    int body_id = robot.get_body_part_id();
    double chassis_x = mesh_info.get_body_size(body_id, 0) * robot.body_scales[0];
    double chassis_y = mesh_info.get_body_size(body_id, 1) * robot.body_scales[1];
    double chassis_z = mesh_info.get_body_size(body_id, 2) * robot.body_scales[2];
    oss << "<link name = \"chassis\">" << std::endl;
    oss << " <visual>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    oss << "    <mesh filename = \"" << mesh_info.body_mesh_dir << "/" << body_id << mesh_ext << "\""
                                     << " scale = \"" << mesh_info.scale_x * robot.body_scales[0] << " "
                                                      << mesh_info.scale_y * robot.body_scales[1] << " "
                                                      << mesh_info.scale_z * robot.body_scales[2] << "\" />" << std::endl;
    // oss << "    <box size=\"" << chassis_x << " " << chassis_y << " " << chassis_z << "\"/>" << std::endl;
    oss << "  </geometry>" << std::endl;
    oss << " </visual>" << std::endl;
    // Add a box for chassis collision
    oss << " <collision>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    oss << "    <box size=\"" << chassis_x * 0.95 << " " << chassis_y * 0.95 << " " << chassis_z * 0.95 << "\"/>" << std::endl;
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
    double leg_pos_tmp;
    double leg_pos_x_tmp;
    double leg_pos_y_tmp;
    double link_z_offset;
    std::string link_name_tmp;
    int num_legs = robot.num_legs;
    int part_ids[3];
    double part_lengths[3];
    double link_length_scale[3];
    for (int i = 0; i < num_legs; ++i) {
        const auto& robot_leg = robot.legs[i];
        link_z_offset = 0;
        int num_links = robot_leg.num_links;
        double leg_length = 0;
        for (int j = 0; j < num_links; ++j) {
            const auto& leg_link = robot_leg.links[j];
            part_ids[j] = robot.get_link_part_id(i, j);
            part_lengths[j] = mesh_info.get_leg_size(part_ids[j], 2);
            link_length_scale[j] = leg_link.scale;
            leg_length += part_lengths[j] * link_length_scale[j];
        }
        // Disbale the leg length adjustment -- let user figure this out!
        // if (leg_length > leg_length_ref) {
            // double rate = leg_length_ref / leg_length;
            // for (int j = 0; j < num_links; ++j)
                // link_length_scale[j] *= rate;
        // }
        for (int j = 0; j < num_links; ++j) {
            oss << "<link name = \"leg_" << i << "-" << j << "\">" << std::endl;
            oss << " <visual>" << std::endl;
            oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 " << part_lengths[j] * link_length_scale[j] * -0.5 << "\" />" << std::endl;
            oss << "  <geometry>" << std::endl;
            oss << "    <mesh filename = \"" << mesh_info.leg_mesh_dir << "/" << part_ids[j] << mesh_ext << "\""
                                             << " scale = \"" << mesh_info.scale_x << " "
                                                              << mesh_info.scale_y << " "
                                                              << mesh_info.scale_z * link_length_scale[j] << "\" />" << std::endl;
            oss << "  </geometry>" << std::endl;
            oss << " </visual>" << std::endl;
            // only enable collision detection on foot
            if (j == num_links - 1) {
            // TODO: add collision sphere to the feet
            // need to figure out the length of each leg from robogami
                oss << " <collision>" << std::endl;
                oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 " << part_lengths[j] * link_length_scale[j] * -1 << "\" />" << std::endl;
                oss << "  <geometry>" << std::endl;
                oss << "    <sphere radius = \"0.01\"/>" << std::endl;
                oss << "  </geometry>" << std::endl;
                oss << " </collision>" << std::endl;
                oss << " <collision>" << std::endl;
                oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
                oss << "  <geometry>" << std::endl;
                oss << "    <sphere radius = \"0.01\"/>" << std::endl;
                oss << "  </geometry>" << std::endl;
                oss << " </collision>" << std::endl;
            } else if (j == num_links - 2) {
                oss << " <collision>" << std::endl;
                oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 " << part_lengths[j] * link_length_scale[j] * -1 + 0.02 << "\" />" << std::endl;
                oss << "  <geometry>" << std::endl;
                oss << "    <sphere radius = \"0.01\"/>" << std::endl;
                oss << "  </geometry>" << std::endl;
                oss << " </collision>" << std::endl;
                oss << " <collision>" << std::endl;
                oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
                oss << "  <geometry>" << std::endl;
                oss << "    <sphere radius = \"0.01\"/>" << std::endl;
                oss << "  </geometry>" << std::endl;
                oss << " </collision>" << std::endl;
            }
            oss << " <inertial>" << std::endl;
            oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
            oss << "  <mass value = \"" << "1" << "\" />" << std::endl;
            oss << "  <inertia ixx = \"" << "1" << "\" ixy = \"" << "0" << "\" ixz = \"" << "0" << "\" iyy = \"" << "1" << "\" iyz = \"" << "0" << "\" izz = \"" << "1" << "\" />" << std::endl;
            oss << " </inertial>" << std::endl;
            oss << "</link>" << std::endl;
            oss << std::endl;

            // joint
            if (j == 0) {
                oss << "<joint name = \"chassis_leg_" << i << "-0\" type = \"continuous\">" << std::endl;
                oss << "  <parent link = \"chassis\"/>" << std::endl;
                // position: [0, 0.5] - FL->BL, [0.5, 1] - BR->FR
                leg_pos_tmp = robot_leg.position; // now the pos gene is in [0, 1]
                leg_pos_y_tmp = chassis_y * 0.5 + mesh_info.get_leg_size(part_ids[j], 1) * 0.5 + 0.05;
                if (leg_pos_tmp < 0.5) {
                    leg_pos_x_tmp = (0.25 - leg_pos_tmp) * 2 * chassis_x;
                } else {
                    leg_pos_x_tmp = (leg_pos_tmp - 0.75) * 2 * chassis_x;
                    leg_pos_y_tmp *= -1;
                }
            } else {
                oss << "<joint name = \"leg_" << i << "-" << j - 1 << "_leg_" << i << "-" << j << "\" type = \"continuous\">" << std::endl;
                oss << "  <parent link = \"leg_" << i << "-" << j - 1 << "\"/>" << std::endl;
                leg_pos_x_tmp = 0;
                leg_pos_y_tmp = 0;
            }
            oss << "  <child link = \"leg_" << i << "-" << j << "\"/>" << std::endl;
            oss << "   <origin xyz = \"" << leg_pos_x_tmp << " " << leg_pos_y_tmp << " " << link_z_offset << " \" rpy = \"0 0 0\" />" << std::endl;
            oss << "   <axis xyz = \"0 1 0\" />" << std::endl;
            oss << "</joint>" << std::endl;
            oss << std::endl;
            link_z_offset = -(part_lengths[j] * link_length_scale[j] + 0.01);
        } // for links
    } // for legs

    oss << "</robot>" << std::endl;

    return oss.str();
}

std::string generate_demo_robogami_robot_string(const std::string& mode,
                                                const std::vector<double>& dv,
                                                const std::string& robot_name) {
    return generate_demo_robogami_robot_string(mode, RobotRepresentation(dv), robot_name);
}

void generate_demo_robogami_robot_file(const std::string& mode,
                                       const RobotRepresentation& robot,
                                       const std::string& robot_name) {
    std::string output_file(Robot_Output_Dir + "/" + robot_name + "/" + robot_name + ".urdf");

    std::filesystem::path output_path(output_file);
    output_path.remove_filename();
    if (!std::filesystem::exists(output_path))
        std::filesystem::create_directory(output_path);

    std::ofstream ofs(output_file.c_str(), std::ostream::out);
    ofs << generate_demo_robogami_robot_string(mode, robot, robot_name);
    ofs.close();
}

void generate_demo_robogami_robot_file(const std::string& mode,
                                       const std::vector<double>& dv,
                                       const std::string& robot_name) {
    generate_demo_robogami_robot_file(mode, RobotRepresentation(dv), robot_name);
}

void set_mesh_dir(const std::string& new_root) {
    mesh_info.set_mesh_dir(new_root);
}
