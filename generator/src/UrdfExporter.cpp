#include "UrdfExporter.h"

#include <map>
#include <list>
#include <fstream>
#include <filesystem>

#include "FBE_Temp/articulation.h"
#include "FBE_Temp/geometry.h"
#include "FBE_Temp/template.h"
#include "FBE_Proto/TemplateProtoConverter.h"
#include "FBE_Kinematics/KinChain.h"

#include "evo_paths.h"

using namespace FabByExample;

void protoToUrdf(const std::string& protfilename, const std::string& robotname) {
    const std::string mesh_ext = ".obj";
    constexpr double scale_x = 0.001;
    constexpr double scale_y = 0.001;
    constexpr double scale_z = 0.001;

    std::string output_file(Robot_Output_Dir + "/" + robotname + "/" + robotname + ".urdf");

    std::filesystem::path output_path(output_file);
    output_path.remove_filename();
    if (!std::filesystem::exists(output_path))
        std::filesystem::create_directory(output_path);

    TemplateProtoConverter converter;
    auto protoRead = converter.loadFromFile(protfilename.c_str());
    Template *robottemp = converter.ConvertToTemplate(*protoRead);

    std::ofstream ofs(output_file.c_str(), std::ofstream::out);

    ofs << "<?xml verison=\"1.0\"?>" << std::endl;
    ofs << "<robot name =\"" << robotname << "\">" << std::endl;
    ofs << std::endl;

    KinChain *kinchain = new KinChain(robottemp);

    std::list<KinNode*> nodelist = kinchain->getNodes();
    std::map<KinNode_Part*, int> node2ind;
    std::map<int, KinNode_Part*> ind2node;
    int i = 0;
    for (auto node : nodelist) {
        if (node->getType() == KinNode::KinNodeType::PART) {
            KinNode_Part *mypart = dynamic_cast<KinNode_Part*>(node);
            node2ind.insert(std::pair<KinNode_Part*, int>(mypart, i));
            ind2node.insert(std::pair<int, KinNode_Part*>(i, mypart));

            // convert link to mesh
            std::string output_file(output_path.string() + "/" + robotname + std::to_string(i) + mesh_ext);
            mypart->getCurrentGeoRelativeToRoot()->write(output_file);

            i++;
        }
    }

    KinNode_Part *rootpart = dynamic_cast<KinNode_Part*>(kinchain->getRoot());
    int rootindex = node2ind.find(rootpart)->second;

    // output the base_link
    ofs << "<link name = \"base_link\">" << std::endl;
    ofs << " <visual>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <geometry>" << std::endl;
    ofs << "    <mesh filename = \"./" << robotname << rootindex << mesh_ext << "\"" << " scale = \"" << scale_x << " " << scale_y << " " << scale_z << "\" />" << std::endl;
    ofs << "  </geometry>" << std::endl;
    ofs << " </visual>" << std::endl;
    ofs << " <collision>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <geometry>" << std::endl;
    ofs << "    <mesh filename = \"./" << robotname << rootindex << mesh_ext << "\"" << " scale = \"" << scale_x << " " << scale_y << " " << scale_z << "\" />" << std::endl;
    ofs << "  </geometry>" << std::endl;
    ofs << " </collision>" << std::endl;
    ofs << " <inertial>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <mass value = \"" << "1" << "\" />" << std::endl;
    ofs << "  <inertia ixx = \"" << "1" << "\" ixy = \"" << "0" << "\" ixz = \"" << "0" << "\" iyy = \"" << "1" << "\" iyz = \"" << "0" << "\" izz = \"" << "1" << "\" />" << std::endl;
    ofs << " </inertial>" << std::endl;
    ofs << "</link>" << std::endl;
    ofs << std::endl;

    // traverse the kinematic tree and convert child joints/links
    for (auto node : nodelist) {
        if (node->getType() == KinNode::KinNodeType::JOINT) {
            KinNode_Joint *myjoint = dynamic_cast<KinNode_Joint*>(node);
            KinNode_Part *parentpart = dynamic_cast<KinNode_Part*>(myjoint->parent);
            std::vector<KinNode*> children = myjoint->children;
            std::string parentname;
            if (parentpart == rootpart) {
                parentname = "base_link";
            }
            else {
                parentname = "link" + std::to_string(node2ind.find(parentpart)->second);
            }
            std::string childname;
            for (auto child : children) {
                KinNode_Part *childpart = dynamic_cast<KinNode_Part*>(child);
                childname = "link" + std::to_string(node2ind.find(childpart)->second);
                Articulation *art = myjoint->getArticulation();
                Eigen::Vector3d center = art->getCenter();

                // Visualization
                ofs << "<link name = \"" << childname << "\">" << std::endl;
                ofs << " <visual>" << std::endl;
                ofs << "  <origin rpy = \"0 0 0\" xyz = \"" << -center[0] * scale_x << " " << -center[1] * scale_y << " " << -center[2] * scale_z << "\" />" << std::endl;
                ofs << "  <geometry>" << std::endl;
                ofs << "    <mesh filename = \"./" << robotname << node2ind.find(childpart)->second << mesh_ext << "\"" << " scale = \"" << scale_x << " " << scale_y << " " << scale_z << "\" />" << std::endl;
                ofs << "  </geometry>" << std::endl;
                ofs << " </visual>" << std::endl;

                // Collision
                ofs << " <collision>" << std::endl;
                ofs << "  <origin rpy = \"0 0 0\" xyz = \"" << -center[0] * scale_x << " " << -center[1] * scale_y << " " << -center[2] * scale_z << "\" />" << std::endl;
                ofs << "  <geometry>" << std::endl;
                ofs << "    <mesh filename = \"./" << robotname << node2ind.find(childpart)->second << mesh_ext << "\"" << " scale = \"" << scale_x << " " << scale_y << " " << scale_z << "\" />" << std::endl;
                ofs << "  </geometry>" << std::endl;
                ofs << " </collision>" << std::endl;

                // Inertial
                ofs << " <inertial>" << std::endl;
                ofs << "  <origin rpy = \"0 0 0\" xyz = \"" << -center[0] * scale_x << " " << -center[1] * scale_y << " " << -center[2] * scale_z << "\" />" << std::endl;
                ofs << "  <mass value = \"" << "1" << "\" />" << std::endl;
                ofs << "  <inertia ixx = \"" << "1" << "\" ixy = \"" << "0" << "\" ixz = \"" << "0" << "\" iyy = \"" << "1" << "\" iyz = \"" << "0" << "\" izz = \"" << "1" << "\" />" << std::endl;
                ofs << " </inertial>" << std::endl;
                ofs << "</link>" << std::endl;
                ofs << std::endl;

                // Joint
                ofs << "<joint name = \"" << parentname << "_" << childname << "\" type = \"continuous\">" << std::endl;
                ofs << "  <parent link = \"" << parentname << "\"/>" << std::endl;
                ofs << "  <child link = \"" << childname << "\"/>" << std::endl;
                ofs << "   <origin xyz = \"" << center[0] * scale_x << " " << center[1] * scale_y << " " << center[2] * scale_z << "\" rpy = \"0 0 0\" />" << std::endl;
                ofs << "   <axis xyz = \"" << art->transformations[0]->axis[0] << " " << art->transformations[0]->axis[1] << " " << art->transformations[0]->axis[2] << "\" />" << std::endl;
                ofs << "</joint>" << std::endl;
                ofs << std::endl;
            }
        }
    }

    ofs << "</robot>" << std::endl;
    ofs.close();
}

