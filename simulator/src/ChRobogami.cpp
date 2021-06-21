#include "ChRobogami.h"

#include <iostream>
#include <filesystem>
#include <chrono/assets/ChBoxShape.h>
#include <chrono/assets/ChSphereShape.h>
#include <chrono/assets/ChCylinderShape.h>
#include <chrono/assets/ChTriangleMeshShape.h>
#include <KinChain.h>
#include <TemplateProtoConverter.h>
#include <CenterOfMass.h>
#include <geometry.h>
#include <articulation.h>

namespace chrono {
static constexpr double robogami_scale_x = 0.01;
static constexpr double robogami_scale_y = 0.01;
static constexpr double robogami_scale_z = 0.01;
static constexpr double robogami_scale_mass = 0.001;

bool ChRobogami::LoadRobotFile(const std::string& protofile) {
    FabByExample::TemplateProtoConverter converter;
    auto protoRead = converter.loadFromFile(protofile);
    template_ = std::shared_ptr<FabByExample::Template>(converter.ConvertToTemplate(*protoRead));
    template_->updateFullQ(template_->getFullQ());
    template_->recomputeCenter();
    template_->translate(-template_->getCenter());
    template_->updateFullQ(template_->getFullQ());
    return true;
}

bool ChRobogami::LoadRobotTemplate(const std::shared_ptr<FabByExample::Template>& robot_template) {
    template_ = robot_template;
    template_->updateFullQ(template_->getFullQ());
    template_->recomputeCenter();
    template_->translate(-template_->getCenter());
    template_->updateFullQ(template_->getFullQ());
    return true;
}

std::shared_ptr<geometry::ChTriangleMeshConnected>
get_triangle_geometry(FabByExample::Geometry *fbe_geometry) {
    fbe_geometry->simplifyMesh();
    auto& vertices = fbe_geometry->mesh->vertices;
    auto& faces = fbe_geometry->mesh->faces;
    auto trimesh = chrono_types::make_shared<geometry::ChTriangleMeshConnected>();

    int v0, v1, v2;
    for (int i = 0; i < faces.size(); i++) {
        v0 = faces[i].v[0];
        v1 = faces[i].v[1];
        v2 = faces[i].v[2];
        trimesh->addTriangle(ChVector<>(vertices[v0][0], vertices[v0][1], vertices[v0][2]),
                             ChVector<>(vertices[v1][0], vertices[v1][1], vertices[v1][2]),
                             ChVector<>(vertices[v2][0], vertices[v2][1], vertices[v2][2]));
    }

    return trimesh;
}

// TODO: Robogami template is Y-up
bool ChRobogami::AddtoSystem(const std::shared_ptr<ChSystem>& sys,
                             const ChCoordsys<>& init_coord) {
    FabByExample::KinChain kinchain(template_.get());
    ch_link_bodies_.clear();
    ch_system_ = sys;
    std::map<FabByExample::KinNode_Part*, std::shared_ptr<ChBody>> fbe2ch;
    auto& CoM_robot = kinchain.getCenterOfMass().center;

    // Bodies
    FabByExample::KinNode_Part *rootpart = dynamic_cast<FabByExample::KinNode_Part*>(kinchain.getRoot());
    auto collision_material = chrono_types::make_shared<ChMaterialSurfaceNSC>();
    std::list<FabByExample::KinNode*> nodes = kinchain.getNodes();
    int link_idx = 0;
    for (auto& node : nodes) {
        if (node->getType() == FabByExample::KinNode::KinNodeType::PART) {
            FabByExample::KinNode_Part *kpart = dynamic_cast<FabByExample::KinNode_Part*>(node);

            std::shared_ptr<ChBody> ch_body;

            bool body_use_aux = false;
            if (auxrefs_ && auxrefs_->find(ch_body->GetNameString()) != auxrefs_->end()){
                ch_body = chrono_types::make_shared<ChBodyAuxRef>();
                body_use_aux = true;
            } else {
                ch_body = chrono_types::make_shared<ChBody>();
                body_use_aux = false;
            }
            ch_body->SetNameString("link_" + std::to_string(link_idx++));

            ChVector<> pos_in_parent(0);
            ChCoordsys<> coord_in_world;
            if (kpart == rootpart) {
                ch_root_body_ = ch_body;
                coord_in_world = init_coord;
            } else {
                FabByExample::KinNode_Joint *parent_joint =
                    dynamic_cast<FabByExample::KinNode_Joint*>(node->parent);
                auto& pos_tmp = parent_joint->getArticulation()->getCenter();
                // Robogami is Y-up, apply Y-to-Z transformation here
                pos_in_parent.x() =  pos_tmp.x() * robogami_scale_x;
                pos_in_parent.y() = -pos_tmp.z() * robogami_scale_z;
                pos_in_parent.z() =  pos_tmp.y() * robogami_scale_y;
                coord_in_world =
                    init_coord.TransformLocalToParent(ChCoordsys<>(pos_in_parent));
            }

            if (body_use_aux) {
                std::dynamic_pointer_cast<ChBodyAuxRef>(ch_body)->SetFrame_REF_to_abs(ChFrame<>(coord_in_world));
                std::dynamic_pointer_cast<ChBodyAuxRef>(ch_body)->SetFrame_COG_to_REF(ChFrame<>(VNULL));
            } else {
                ch_body->SetCoord(coord_in_world);
            }
            ch_body->SetRot(Q_ROTATE_Y_TO_Z);

            fbe2ch[kpart] = ch_body;

            // Inertial
            // TODO: hardcoded mass scale
            ch_body->SetMass(node->getCenter().mass *robogami_scale_mass);
            // TODO: figure out inertia matrix

            // Visual
            auto& CoM_part = node->getCenter().center;
            FabByExample::Geometry *geom = kpart->getGeometry();
            geom->applyTrans(point(-CoM_robot.x(), -CoM_robot.y(), -CoM_robot.z()));
            geom->applyTrans(point(-CoM_part.x(), -CoM_part.y(), -CoM_part.z()));

            auto trimesh = get_triangle_geometry(geom);
            // TODO: Hardcoded values mesh scale
            trimesh->Transform(VNULL, ChMatrix33<>(ChVector<>(robogami_scale_x, robogami_scale_y, robogami_scale_z)));
            trimesh->RepairDuplicateVertexes(1e-9); // if meshes are not watertight
            auto trimesh_shape = chrono_types::make_shared<ChTriangleMeshShape>();
            trimesh_shape->SetMesh(trimesh);
            trimesh_shape->SetName(ch_body->GetNameString() + "_vis_mesh");
            trimesh_shape->SetBackfaceCull(true);
            trimesh_shape->SetStatic(true); // mesh object is considered static if it's non-deformable
            // TODO: the following position logic is copied form robogami's simpleURDF,
            // not sure what's going on here. Same in pos of collision shape
            trimesh_shape->Pos = -pos_in_parent;
            trimesh_shape->Rot = ChMatrix33<>(QUNIT); // the visual orientation in body frame
            ch_body->AddAsset(trimesh_shape);

            // Collision
            ch_body->GetCollisionModel()->ClearModel();
            ch_body->GetCollisionModel()->AddTriangleMesh(collision_material,
                                                          trimesh,
                                                          false,  // is static
                                                          true,  // use convex hull
                                                          -pos_in_parent,
                                                          ChMatrix33<>(QUNIT), // the collision orientation in body frame
                                                          -0.01); // sphereswept_thickness
            ch_body->GetCollisionModel()->BuildModel();
            ch_body->SetCollide(true);

            ch_system_->AddBody(ch_body);
        }
    }

    // Joints
    for (auto& node : nodes) {
        if (node->getType() == FabByExample::KinNode::KinNodeType::JOINT) {
            FabByExample::KinNode_Joint* kjoint = dynamic_cast<FabByExample::KinNode_Joint*>(node);
            FabByExample::KinNode_Part* k_parent_part = dynamic_cast<FabByExample::KinNode_Part*>(kjoint->parent);
            auto& ch_parent_body = fbe2ch[k_parent_part];

            // the number of children could be 1 or 0, so use a for loop here
            // TODO: better way to deal with this
            for (auto& child : kjoint->children) {
                FabByExample::KinNode_Part* k_child_part = dynamic_cast<FabByExample::KinNode_Part*>(child);
                auto& ch_child_body = fbe2ch[k_child_part];
                Eigen::Vector3d axis = kjoint->getArticulation()->transformations[0]->axis;
                auto ch_link = chrono_types::make_shared<ChLinkLockRevolute>();
                ch_link->Initialize(ch_child_body,
                                    ch_parent_body,
                                    ChCoordsys<>(ch_child_body->GetFrame_REF_to_abs().GetPos(),
                                                 Q_from_Vect_to_Vect(VECT_Z,
                                                                     ChVector<>(axis[0],
                                                                                axis[1],
                                                                                axis[2])).GetNormalized() >> ch_child_body->GetFrame_REF_to_abs().GetRot()));
                // TODO: Joint dynamics - friction, damping

                ch_link->SetNameString(ch_parent_body->GetNameString() + "_" + ch_child_body->GetNameString());
                ch_link_bodies_.emplace(ch_link->GetNameString(), ChLinkBodies{ch_link, ch_child_body, ch_parent_body});
                ch_system_->AddLink(ch_link);
            }
        }
    }

    return true;
}

}  // namespace chrono
