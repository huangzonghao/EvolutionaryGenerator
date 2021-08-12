#include "RobotRepresentation.h"
#include <iostream>

RobotRepresentation::Leg::Leg(int myid, int total_legs) { update_pos(myid, total_legs); }

void RobotRepresentation::Leg::update_pos(int myid, int total_legs) {
    position = get_pos(myid, total_legs);
}

RobotRepresentation::RobotRepresentation() {
    for (int i = 0; i < num_legs; ++i)
        legs[i].update_pos(i, num_legs);
    encode_design_vector();
}

// dv format: [body_id, body_x, body_y, body_z, num_legs, leg_1, leg_2, ...]
//     for each leg: [leg_pos, num_links, link_1_id, link_1_scale]
void RobotRepresentation::encode_design_vector() {
    design_vector.clear();
    design_vector.push_back(body_part_id);
    for (int i = 0; i < 3; ++i)
        design_vector.push_back(body_scales[i]);
    design_vector.push_back(num_legs);
    for (int i = 0; i < num_legs; ++i) {
        const auto& tmp_leg = legs[i];
        design_vector.push_back(tmp_leg.position);
        design_vector.push_back(tmp_leg.num_links);
        for (int j = 0; j < tmp_leg.num_links; ++j) {
            const auto& tmp_link = tmp_leg.links[j];
            design_vector.push_back(tmp_link.part_id);
            design_vector.push_back(tmp_link.scale);
        }
    }
}

void RobotRepresentation::decode_design_vector() {
    int cursor = 0;
    body_part_id = design_vector[cursor++];
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
            tmp_link.part_id = design_vector[cursor++];
            tmp_link.scale = design_vector[cursor++];
        }
    }
}

void RobotRepresentation::decode_design_vector(const std::vector<double>& new_dv) {
    design_vector = new_dv;
    decode_design_vector();
}

std::ostream& operator<<(std::ostream& os, const RobotRepresentation& robot) {
    for (size_t i = 0; i < robot.design_vector.size() - 1; ++i)
        os << robot.design_vector[i] << ", ";
    os << robot.design_vector.back();
    return os;
}
