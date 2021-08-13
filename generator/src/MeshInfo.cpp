#include "MeshInfo.h"

#include <iostream>
#include <TriMesh.h>

MeshInfo::MeshInfo() {
    for (int i = 0; i < num_bodies; ++i) {
        TriMesh *mesh_tmp = TriMesh::read(std::string(body_tmp_dir + "/" + std::to_string(i) + ".obj").c_str());
        mesh_tmp->need_bbox();
        const auto& bbox_size = mesh_tmp->bbox.size();
        body_size.push_back({bbox_size[0] * scale_x, bbox_size[1] * scale_y, bbox_size[2] * scale_z});
        delete mesh_tmp;
    }
    for (int i = 0; i < num_legs; ++i) {
        TriMesh *mesh_tmp = TriMesh::read(std::string(leg_tmp_dir + "/" + std::to_string(i) + ".obj").c_str());
        mesh_tmp->need_bbox();
        const auto& bbox_size = mesh_tmp->bbox.size();
        leg_size.push_back({bbox_size[0] * scale_x, bbox_size[1] * scale_y, bbox_size[2] * scale_z});
        delete mesh_tmp;
    }
}

void MeshInfo::print_all_size() {
    std::cout << "Size of bodies:" << std::endl;
    for (int i = 0; i < num_bodies; ++i)
        std::cout << i << ": " << body_size[i][0] << ", " << body_size[i][1] << ", " << body_size[i][2] << std::endl;
    std::cout << "Size of legs:" << std::endl;
    for (int i = 0; i < num_legs; ++i)
        std::cout << i << ": " << leg_size[i][0] << ", " << leg_size[i][1] << ", " << leg_size[i][2] << std::endl;
}

double MeshInfo::get_body_size(int body_id, int dim) const {
    return body_size[body_id][dim];
}

double MeshInfo::get_leg_size(int leg_id, int dim) const {
    return leg_size[leg_id][dim];
}

MeshInfo mesh_info;
