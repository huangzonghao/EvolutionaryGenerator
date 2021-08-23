#include "RobotRepresentation.h"
#include <algorithm>
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

bool RobotRepresentation::Leg::operator<(const RobotRepresentation::Leg& other) const {
    return position < other.position;
}

RobotRepresentation::RobotRepresentation() {
    for (int i = 0; i < num_legs; ++i)
        legs[i].update_pos(i, num_legs);
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
    os << "Num of legs: " << robot.num_legs << std::endl;
    for (int i = 0; i < robot.num_legs; ++i) {
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
