#include "MeshInfo.h"

#include <iostream>
#include <TriMesh.h>

void MeshInfo::load_info() {
    body_size.clear();
    for (int i = 0; i < num_bodies; ++i) {
        TriMesh *mesh_tmp = TriMesh::read(std::string(body_mesh_dir + "/" + std::to_string(i) + ".obj").c_str());
        mesh_tmp->need_bbox();
        const auto& bbox_size = mesh_tmp->bbox.size();
        body_size.push_back({bbox_size[0] * scale_x, bbox_size[1] * scale_y, bbox_size[2] * scale_z});
        delete mesh_tmp;
    }
    leg_size.clear();
    for (int i = 0; i < num_legs; ++i) {
        TriMesh *mesh_tmp = TriMesh::read(std::string(leg_mesh_dir + "/" + std::to_string(i) + ".obj").c_str());
        mesh_tmp->need_bbox();
        const auto& bbox_size = mesh_tmp->bbox.size();
        leg_size.push_back({bbox_size[0] * scale_x, bbox_size[1] * scale_y, bbox_size[2] * scale_z});
        delete mesh_tmp;
    }
}

MeshInfo::MeshInfo() { load_info(); }

void MeshInfo::set_mesh_dir(const std::string& new_root) {
    body_mesh_dir = new_root + "/bodies";
    leg_mesh_dir = new_root + "/legs";
    load_info();
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
