#include "GenerateDemoRobogamiRobot.h"

#include <map>
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#include <filesystem>
// #include "RobogamiLibrary.h"
#include "robogami_paths.h"
#include "evo_paths.h"

constexpr double leg_length_ref = 0.085 * 1.2;
constexpr int robogami_lib_num_bodies = 5;
constexpr int robogami_lib_num_legs = 11;

std::string body_tmp_dir(Robot_Output_Dir + "/tmp_robot_parts/body");
std::string leg_tmp_dir(Robot_Output_Dir + "/tmp_robot_parts/leg");

struct rbiBody {
    double x;
    double y;
    double z;
};

void init_robogami_library() {
    // RobogamiLibrary robogami_lib(Robogami_Data_Dir + "/proto");
    // robogami_lib.OutputMeshFiles(Robot_Output_Dir + "/tmp_robot_parts");
}

// phen format: [body_x, body_y, body_z, num_legs, leg_1, leg_2, ...]
//     for each leg: [leg_pos, num_links, link_1_id, link_1_scale]
std::string generate_demo_robogami_robot_string(const std::string& mode,
                                                const std::vector<double>& dv,
                                                const std::string& robot_name) {
    const std::string mesh_ext = ".obj";
    const std::string leg_mesh_path = Robot_Output_Dir + "tmp_robot_parts/leg";
    constexpr double leg_std_length = 0.1;
    constexpr double scale_x = 0.01;
    constexpr double scale_y = 0.01;
    constexpr double scale_z = 0.01;
    std::ostringstream oss;

    oss << "<?xml verison=\"1.0\"?>" << std::endl;
    oss << "<robot name =\"" << robot_name << "\">" << std::endl;
    oss << std::endl;

    // TODO: Temporarily use fixed body mesh
    // chassis
    rbiBody chassis;
    chassis.x = 0.4 * dv[0];
    chassis.y = 0.2 * dv[1];
    chassis.z = 0.05 * dv[2];
    double chassis_extra_scales[3] {dv[0] * 0.2 * 6 / 4, dv[1] * 0.25, 0.1};
    oss << "<link name = \"chassis\">" << std::endl;
    oss << " <visual>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    oss << "    <mesh filename = \"" << body_tmp_dir << "/0" << mesh_ext << "\"" << " scale = \"" << scale_x * chassis_extra_scales[0] << " "
                                                                                                  << scale_y * chassis_extra_scales[1] << " "
                                                                                                  << scale_z * chassis_extra_scales[2] << "\" />" << std::endl;
    // oss << "    <box size=\"" << chassis.x << " " << chassis.y << " " << chassis.z << "\"/>" << std::endl;
    oss << "  </geometry>" << std::endl;
    oss << " </visual>" << std::endl;
    // oss << " <collision>" << std::endl;
    // oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    // oss << "  <geometry>" << std::endl;
    // // oss << "    <mesh filename = \"" << body_tmp_dir << "/" << 0 << mesh_ext << "\"" << " scale = \"" << scale_x << " " << scale_y << " " << scale_z << "\" />" << std::endl;
    // oss << "    <box size=\"" << chassis.x << " " << chassis.y << " " << chassis.z << "\"/>" << std::endl;
    // oss << "  </geometry>" << std::endl;
    // oss << " </collision>" << std::endl;
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
    double leg_extra_scales[3];
    std::string link_name_tmp;
    int num_legs = dv[3];
    int cursor = 5;
    int part_ids[3];
    for (int i = 0; i < num_legs; ++i) {
        link_z_offset = 0;
        int num_links = dv[cursor];
        double leg_length = 0;
        for (int j = 0; j < num_links; ++j) {
            part_ids[j] = int(dv[cursor+1+j*2]);
            leg_extra_scales[j] = dv[cursor+1+j*2+1];
            leg_length += leg_std_length * leg_extra_scales[j];
        }
        if (leg_length > leg_length_ref) {
            double rate = leg_length_ref / leg_length;
            for (int j = 0; j < num_links; ++j)
                leg_extra_scales[j] *= rate;
        }
        for (int j = 0; j < num_links; ++j) {
            oss << "<link name = \"leg_" << i << "-" << j << "\">" << std::endl;
            oss << " <visual>" << std::endl;
            oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 " << leg_std_length * leg_extra_scales[j] * -0.5 << "\" />" << std::endl;
            oss << "  <geometry>" << std::endl;
            oss << "    <mesh filename = \"" << leg_tmp_dir << "/" << part_ids[j] << mesh_ext << "\"" << " scale = \"" << scale_x * leg_extra_scales[j] << " " << scale_y * leg_extra_scales[j] << " " << scale_z * leg_extra_scales[j] << "\" />" << std::endl;
            oss << "  </geometry>" << std::endl;
            oss << " </visual>" << std::endl;
            // only enable collision detection on foot
            if (j == num_links - 1) {
            // TODO: add collision sphere to the feet
            // need to figure out the length of each leg from robogami
                oss << " <collision>" << std::endl;
                oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 " << leg_std_length * leg_extra_scales[j] * -1 << "\" />" << std::endl;
                oss << "  <geometry>" << std::endl;
                oss << "    <sphere radius = \"0.01\"/>" << std::endl;
                oss << "  </geometry>" << std::endl;
                oss << " </collision>" << std::endl;
                oss << " <collision>" << std::endl;
                oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 " << leg_std_length * leg_extra_scales[j] * 1 << "\" />" << std::endl;
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
                leg_pos_tmp = dv[cursor-1]; // now the pos gene is in [0, 1]
                if (leg_pos_tmp < 0.5) {
                    leg_pos_x_tmp = (0.25 - leg_pos_tmp) * 4 * (chassis.x / 2);
                    leg_pos_y_tmp = chassis.y / 2 + 0.05;
                } else {
                    leg_pos_x_tmp = (leg_pos_tmp - 0.75) * 4 * (chassis.x / 2);
                    leg_pos_y_tmp = -(chassis.y / 2 + 0.05);
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
            link_z_offset = -(leg_std_length * leg_extra_scales[j] + 0.01);
        } // for links
        cursor += num_links * 2 + 2; // offsets include leg_pos and num_links
    } // for legs

    oss << "</robot>" << std::endl;

    return oss.str();
}

void generate_demo_robogami_robot_file(const std::string& mode,
                                       const std::vector<double>& dv,
                                       const std::string& robot_name) {
    std::string output_file(Robot_Output_Dir + "/" + robot_name + "/" + robot_name + ".urdf");

    std::filesystem::path output_path(output_file);
    output_path.remove_filename();
    if (!std::filesystem::exists(output_path))
        std::filesystem::create_directory(output_path);

    std::ofstream ofs(output_file.c_str(), std::ostream::out);
    ofs << generate_demo_robogami_robot_string(mode, dv, robot_name);
    ofs.close();
}

