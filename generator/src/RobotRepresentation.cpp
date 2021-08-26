#include "RobotRepresentation.h"
#include <algorithm>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <sstream>
#include "MeshInfo.h"

extern MeshInfo mesh_info; // defined in MeshInfo.cpp

RobotRepresentation::Leg::Leg(int myid, int total_legs) { update_pos(myid, total_legs); }

void RobotRepresentation::Leg::update_pos(int myid, int total_legs) {
    position = get_pos(myid, total_legs);
}

double RobotRepresentation::Leg::length() const {
    double length = 0;
    for (int i = 0; i < num_links; ++i) {
        length += mesh_info.get_leg_length(links[i].part_id) * links[i].scale;
    }
    return length;
}

bool RobotRepresentation::Leg::operator<(const RobotRepresentation::Leg& other) const {
    return position < other.position;
}

RobotRepresentation::RobotRepresentation() {
    for (int i = 0; i < num_legs_; ++i)
        legs[i].update_pos(i, num_legs_);
}

void RobotRepresentation::update_num_legs(int new_num_legs) {
    num_legs_ = new_num_legs;
    legs.resize(num_legs_);
    for (int i = 0; i < num_legs_; ++i)
        legs[i].update_pos(i, num_legs_);
}

int RobotRepresentation::get_body_part_id() const {
    return body_part_id;
}

int RobotRepresentation::get_link_part_id(int leg_id, int link_id) const {
    return legs[leg_id].links[link_id].part_id;
}

double RobotRepresentation::get_body_size(int dir) const {
    return mesh_info.get_body_size(body_part_id, dir) * body_scales[dir];
}

int RobotRepresentation::num_legs() const {
    return num_legs_;
}

// return length of body along x direction
double RobotRepresentation::get_body_length() const {
    return get_body_size(0);
}

double RobotRepresentation::get_leg_pos(int leg_id) const {
    return legs[leg_id].position;
}

std::string RobotRepresentation::get_urdf_string_mesh() const {

    const std::string mesh_ext = ".obj";
    std::ostringstream oss;

    oss << "<?xml verison=\"1.0\"?>" << std::endl;
    oss << "<robot name =\"" << robot_name << "\">" << std::endl;
    oss << std::endl;

    // chassis
    double chassis_x = mesh_info.get_body_size(body_part_id, 0) * body_scales[0];
    double chassis_y = mesh_info.get_body_size(body_part_id, 1) * body_scales[1];
    double chassis_z = mesh_info.get_body_size(body_part_id, 2) * body_scales[2];
    oss << "<link name = \"chassis\">" << std::endl;
    oss << " <visual>" << std::endl;
    oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    oss << "  <geometry>" << std::endl;
    oss << "    <mesh filename = \"" << mesh_info.body_mesh_dir << "/" << body_part_id << mesh_ext << "\""
                                     << " scale = \"" << mesh_info.scale_x * body_scales[0] << " "
                                                      << mesh_info.scale_y * body_scales[1] << " "
                                                      << mesh_info.scale_z * body_scales[2] << "\" />" << std::endl;
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
    int num_legs = num_legs_;
    int part_ids[3];
    double part_lengths[3];
    double link_length_scale[3];
    for (int i = 0; i < num_legs; ++i) {
        const auto& robot_leg = legs[i];
        link_z_offset = 0;
        int num_links = robot_leg.num_links;
        double leg_length = 0;
        for (int j = 0; j < num_links; ++j) {
            const auto& leg_link = robot_leg.links[j];
            part_ids[j] = get_link_part_id(i, j);
            part_lengths[j] = mesh_info.get_leg_size(part_ids[j], 2);
            link_length_scale[j] = leg_link.scale;
            leg_length += part_lengths[j] * link_length_scale[j];
        }
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
            if (collision_use_mesh_) {
                oss << " <collision>" << std::endl;
                oss << "  <origin rpy = \"0 0 0\" xyz = \"0 0 " << part_lengths[j] * link_length_scale[j] * -1 + 0.02 << "\" />" << std::endl;
                oss << "  <geometry>" << std::endl;
                oss << "    <mesh filename = \"" << mesh_info.leg_mesh_dir << "/" << part_ids[j] << mesh_ext << "\""
                                                 << " scale = \"" << mesh_info.scale_x << " "
                                                                  << mesh_info.scale_y << " "
                                                                  << mesh_info.scale_z * link_length_scale[j] << "\" />" << std::endl;
                oss << "  </geometry>" << std::endl;
                oss << " </collision>" << std::endl;
            } else {
                // Use spheres for collision detection on feet
                if (j == num_links - 1) {
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

// Temporarily drop this definitions here, the logic should go into a seperate
// class and the constants should be load from a file on disk
constexpr double leg_length_ref = 0.085 * 1.2;

struct Body {
    double x = 0;
    double y = 0;
    double z = 0;
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

std::string RobotRepresentation::get_urdf_string_primitive() const {
    std::ostringstream oss;

    oss << "<?xml verison=\"1.0\"?>" << std::endl;
    oss << "<robot name =\"" << robot_name << "\">" << std::endl;
    oss << std::endl;

    // chassis
    Body chassis;
    chassis.x = 0.6 * body_scales[0];
    chassis.y = 0.2 * body_scales[1];
    chassis.z = 0.05 * body_scales[2];
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
    int num_legs = num_legs_;
    Body bodies[3];
    for (int i = 0; i < num_legs; ++i) {
        const auto& robot_leg = legs[i];
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
                // position: [0, 0.5] - FL->BL, [0.5, 1] - BR->FR
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

std::string RobotRepresentation::get_urdf_string() const {
    if (type == "mesh")
        return get_urdf_string_mesh();
    else if (type == "primitive")
        return get_urdf_string_primitive();
    else {
        std::cout << "Wrong robot type: " << type << std::endl;
        exit(EXIT_FAILURE);
    }
}

void RobotRepresentation::export_urdf_file(const std::string& output_file) const {
    std::filesystem::path output_path(output_file);
    output_path.remove_filename();
    if (!std::filesystem::exists(output_path))
        std::filesystem::create_directories(output_path);

    std::ofstream ofs(output_file, std::ostream::out);
    ofs << get_urdf_string();
    ofs.close();
}

std::ostream& operator<<(std::ostream& os, const RobotRepresentation& robot) {
    os << "Num of legs: " << robot.num_legs_ << std::endl;
    for (int i = 0; i < robot.num_legs_; ++i) {
        const auto& tmp_leg = robot.legs[i];
        os << "    Leg " << std::to_string(i)
                         << ": leg_pos " << tmp_leg.position
                         << ", num_links " << std::to_string(tmp_leg.num_links) << std::endl;
        for (int j = 0; j < tmp_leg.num_links; ++j) {
            const auto& tmp_link = tmp_leg.links[j];
            os << "        link " << std::to_string(j) << ": part_id " << std::to_string(tmp_link.part_id)
                                                       << ", scale " << std::to_string(tmp_link.scale) << std::endl;
        }
    }
    return os;
}
