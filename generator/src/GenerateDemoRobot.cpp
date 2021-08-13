#include "GenerateDemoRobot.h"

#include <map>
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#include <filesystem>

#include "RobotRepresentation.h"
#include "evo_paths.h"

constexpr double leg_length_ref = 0.085 * 1.2;

struct Body {
    double x;
    double y;
    double z;
};

Body body_selector(size_t body_id) {
    Body ret;
    switch (body_id) {
    case 0:
        ret.x = 0.015;
        ret.y = 0.015;
        ret.z = 0.085;
        break;
    case 1:
        ret.x = 0.015;
        ret.y = 0.03;
        ret.z = 0.045;
        break;
    case 2:
        ret.x = 0.03;
        ret.y = 0.01;
        ret.z = 0.1;
        break;
    case 3:
        ret.x = 0.005;
        ret.y = 0.03;
        ret.z = 0.06;
        break;
    default:
        ret.x = 0.015;
        ret.y = 0.015;
        ret.z = 0.085;
        break;
    }
    return ret;
}

Body body_selector(double body_id_gene) {
    size_t body_id;
    if (body_id_gene < 0.25)
        body_id = 0;
    else if (body_id_gene < 0.5)
        body_id = 1;
    else if (body_id_gene < 0.75)
        body_id = 2;
    else
        body_id = 3;

    return body_selector(body_id);
}


std::string generate_demo_robot_string(const std::string& mode,
                                       const std::vector<double>& dv,
                                       const std::string& robot_name) {
    RobotRepresentation robot(dv);
    std::ostringstream oss;

    oss << "<?xml verison=\"1.0\"?>" << std::endl;
    oss << "<robot name =\"" << robot_name << "\">" << std::endl;
    oss << std::endl;

    // chassis
    Body chassis;
    chassis.x = 0.6 * robot.body_scales[0];
    chassis.y = 0.2 * robot.body_scales[1];
    chassis.z = 0.05 * robot.body_scales[2];
    oss << "<link name = \"chassis\">" << std::endl;
    oss << " <visual>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    oss << "    <box size=\"" << chassis.x << " " << chassis.y << " " << chassis.z << "\"/>" << std::endl;
    oss << "  </geometry>" << std::endl;
    oss << " </visual>" << std::endl;
    oss << " <collision>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    oss << "    <box size=\"" << chassis.x << " " << chassis.y << " " << chassis.z << "\"/>" << std::endl;
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
    Body bodies[3];
    for (int i = 0; i < num_legs; ++i) {
        const auto& robot_leg = robot.legs[i];
        link_z_offset = 0;
        int num_links = robot_leg.num_links;
        double leg_length = 0;
        for (int j = 0; j < num_links; ++j) {
            const auto& leg_link = robot_leg.links[j];
            bodies[j] = body_selector(leg_link.part_gene);
            bodies[j].z = bodies[j].z * leg_link.scale; // only z is controlled by design vector
            leg_length += bodies[j].z;
        }
        if (leg_length > leg_length_ref) {
            double rate = leg_length_ref / leg_length;
            for (int j = 0; j < num_links; ++j)
                bodies[j].z = bodies[j].z * rate;
        }
        for (int j = 0; j < num_links; ++j) {
            oss << "<link name = \"leg_" << i << "-" << j << "\">" << std::endl;
            oss << " <visual>" << std::endl;
            oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 " << bodies[j].z * -0.5 << "\" />" << std::endl;
            oss << "  <geometry>" << std::endl;
            oss << "    <box size=\"" << bodies[j].x << " " << bodies[j].y << " " <<  bodies[j].z << "\"/>" << std::endl;
            oss << "  </geometry>" << std::endl;
            oss << " </visual>" << std::endl;
            // only enable collision detection on foot
            if (j == num_links - 1) {
                oss << " <collision>" << std::endl;
                oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 " << bodies[j].z * -0.5 << "\" />" << std::endl;
                oss << "  <geometry>" << std::endl;
                oss << "    <box size=\"" << bodies[j].x << " " << bodies[j].y << " " <<  bodies[j].z << "\"/>" << std::endl;
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
                leg_pos_tmp = robot_leg.position; // now the pos gene is in [0, 1]
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
            link_z_offset = -(bodies[j].z + 0.01);
        } // for links
    } // for legs

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

