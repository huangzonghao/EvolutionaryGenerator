#include "RobotRepresentation.h"
#include <iostream>
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

RobotRepresentation::RobotRepresentation() {
    for (int i = 0; i < num_legs; ++i)
        legs[i].update_pos(i, num_legs);
    encode_design_vector();
}

RobotRepresentation::RobotRepresentation(std::vector<double> new_dv) { decode_design_vector(new_dv); }

// dv format: [body_id, body_x, body_y, body_z, num_legs, leg_1, leg_2, ...]
//     for each leg: [leg_pos, num_links, link_1_id, link_1_scale]
void RobotRepresentation::encode_design_vector() {
    design_vector.clear();
    design_vector.push_back(body_part_gene);
    for (int i = 0; i < 3; ++i)
        design_vector.push_back(body_scales[i]);
    design_vector.push_back(num_legs);
    for (int i = 0; i < num_legs; ++i) {
        const auto& tmp_leg = legs[i];
        design_vector.push_back(tmp_leg.position);
        design_vector.push_back(tmp_leg.num_links);
        for (int j = 0; j < tmp_leg.num_links; ++j) {
            const auto& tmp_link = tmp_leg.links[j];
            design_vector.push_back(tmp_link.part_gene);
            design_vector.push_back(tmp_link.scale);
        }
    }
}

void RobotRepresentation::decode_design_vector() {
    int cursor = 0;
    body_part_gene = design_vector[cursor++];
    body_part_id = std::floor(body_part_gene * mesh_info.num_bodies);
    if (body_part_id == mesh_info.num_bodies)
        body_part_id -= 1;
    for (int i = 0; i < 3; ++i)
        body_scales[i] = design_vector[cursor++];
    num_legs = design_vector[cursor++];
    legs.resize(num_legs);
    for (int i = 0; i < num_legs; ++i) {
        auto& tmp_leg = legs[i];
        tmp_leg.position = design_vector[cursor++];
        tmp_leg.num_links = design_vector[cursor++];
        tmp_leg.links.resize(tmp_leg.num_links);
        for(int j = 0; j < tmp_leg.num_links; ++j) {
            auto& tmp_link = tmp_leg.links[j];
            tmp_link.part_gene = design_vector[cursor++];
            tmp_link.scale = design_vector[cursor++];
            tmp_link.part_id = std::floor(tmp_link.part_gene * mesh_info.num_legs);
            if (tmp_link.part_id == mesh_info.num_legs)
                tmp_link.part_id -= 1;
        }
    }
}

void RobotRepresentation::decode_design_vector(const std::vector<double>& new_dv) {
    design_vector = new_dv;
    decode_design_vector();
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

// return length of body along x direction
double RobotRepresentation::get_body_length() const {
    return get_body_size(0);
}

std::ostream& operator<<(std::ostream& os, const RobotRepresentation& robot) {
    for (size_t i = 0; i < robot.design_vector.size() - 1; ++i)
        os << robot.design_vector[i] << ", ";
    os << robot.design_vector.back();
    return os;
}
