#include <filesystem>
#include <FBE_Temp/geometry.h>
#include <FBE_Temp/template.h>
#include <FBE_Kinematics/KinChain.h>
#include <FBE_Proto/TemplateProtoConverter.h>
#include "RobogamiLibrary.h"

bool RobogamiLibrary::LoadLibrary(const std::string& lib_path) {
    FabByExample::TemplateProtoConverter converter;
    FabByExample::proto::TemplateSet *tmp_proto;
    for (int i = 0; i < body_names.size(); ++i) {
        tmp_proto = converter.loadFromFile(lib_path + "/" + body_names[i] + "/template.asciiproto");
        body_templates_[i] = std::shared_ptr<FabByExample::Template>(converter.ConvertToTemplate(*tmp_proto));
        delete tmp_proto;
    }
    for (int i = 0; i < leg_names.size(); ++i) {
        tmp_proto = converter.loadFromFile(lib_path + "/" + leg_names[i] + "/template.asciiproto");
        leg_templates_[i] = std::shared_ptr<FabByExample::Template>(converter.ConvertToTemplate(*tmp_proto));
        delete tmp_proto;
    }
    return true;
}

std::shared_ptr<FabByExample::Template> RobogamiLibrary::GetBody(size_t idx) const {
    return body_templates_[idx];
}

std::shared_ptr<FabByExample::Template> RobogamiLibrary::GetBody(const std::string& name) const {
    for (int i = 0; i < body_names.size(); ++i) {
        if (body_names.at(i) == name)
            return GetBody(i);
    }
    std::cout << "Error: no body named " << name << " in Robogami Library" << std::endl;
    exit(EXIT_FAILURE);
}

std::shared_ptr<FabByExample::Template> RobogamiLibrary::GetLeg(size_t idx) const {
    return leg_templates_[idx];
}

std::shared_ptr<FabByExample::Template> RobogamiLibrary::GetLeg(const std::string& name) const {
    for (int i = 0; i < leg_names.size(); ++i) {
        if (leg_names.at(i) == name)
            return GetLeg(i);
    }
    std::cout << "Error: no leg named " << name << " in Robogami Library" << std::endl;
    exit(EXIT_FAILURE);
}

void RobogamiLibrary::OutputMeshFiles(const std::string& output_path, const std::string& mesh_type) {
    std::string body_output_dir(output_path + "/bodies");
    std::string leg_output_dir(output_path + "/legs");
    std::filesystem::create_directories(body_output_dir);
    std::filesystem::create_directories(leg_output_dir);
    Eigen::Vector3d origin = Eigen::Vector3d(0, 0, 0);
    Eigen::Quaterniond y_to_z = Eigen::Quaterniond::FromTwoVectors(Eigen::Vector3d(0, 1, 0),
                                                                   Eigen::Vector3d(0, 0, 1));
    Eigen::Matrix3d transform_mat(Eigen::Matrix3d::Identity());
    for (int i = 0; i < body_names.size(); ++i) {
        auto temp = GetBody(i);
        temp->recomputeCenter();
        temp->translate(-temp->getCenter());
        temp->rotate(origin, y_to_z);
        temp->getGeometry()->write(body_output_dir + "/" + std::to_string(i) + "." + mesh_type);
        // TODO: right now hard coding all body width to be 2
        // double x_transform_rate = 40.0 / temp->getLengthX();
        // double transform_rate = 20.0 / temp->getLengthY();
        // transform_mat(0, 0) *= x_transform_rate;
        // transform_mat(1, 1) *= transform_rate;
        // transform_mat(2, 2) *= transform_rate;
        // temp->transform(transform_mat);
        // temp->getGeometry()->write(leg_output_dir + "/" + std::to_string(i) + "." + mesh_type);
        // transform_mat(0, 0) = 1;
        // transform_mat(1, 1) = 1;
        // transform_mat(2, 2) = 1;
        // std::cout << "body " << i << " x length " << temp->getLengthX() << std::endl;
    }
    for (int i = 0; i < leg_names.size(); ++i) {
        auto temp = GetLeg(i);
        temp->recomputeCenter();
        temp->translate(-temp->getCenter());
        temp->updateFullQ(temp->getFullQ());
        temp->rotate(origin, y_to_z);
        temp->getGeometry()->write(leg_output_dir + "/" + std::to_string(i) + "." + mesh_type);
        // TODO: right now I need to force the length of all legs to be 10, so that
        // the mesh file can be used in the urdf generator (otherwise I can't pass
        // the length information to the generator)
        // double transform_rate = 10.0 / temp->getLengthZ();
        // transform_mat(0, 0) *= transform_rate;
        // transform_mat(1, 1) *= transform_rate;
        // transform_mat(2, 2) *= transform_rate;
        // temp->transform(transform_mat);
        // temp->getGeometry()->write(leg_output_dir + "/" + std::to_string(i) + "." + mesh_type);
        // transform_mat(0, 0) = 1;
        // transform_mat(1, 1) = 1;
        // transform_mat(2, 2) = 1;
    }
}

// TODO: ask if there is a way to transform robogami
