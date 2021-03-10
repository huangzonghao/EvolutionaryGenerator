#include "UrdfExporter.h"

#include <map>
#include <list>
#include <fstream>

#include "articulation.h"
#include "geometry.h"
#include "template.h"
#include "TemplateProtoConverter.h"
#include "KinChain.h"

#include "evo_paths.h"

void separateSTLKin(std::string protfilename, std::string robotname, std::string directoryroot) {
    TemplateProtoConverter converter;
    auto protoRead = converter.loadFromFile(protfilename.c_str());
    Template* temp = converter.ConvertToTemplate(*protoRead);

    KinChain* kinchain = new KinChain(temp);
    std::list<KinNode *> mynodes = kinchain->getNodes();
    int i = 0;
    for (auto node : mynodes) {
        if (node->getType() == KinNode::KinNodeType::PART) {
            std::string output_file(directoryroot + "/" + robotname + std::to_string(i) + ".stl");
            KinNode_Part * mypart = dynamic_cast<KinNode_Part*>(node);
            mypart->getCurrentGeoRelativeToRoot()->write(output_file);
            i++;
        }
    }
}

void protoToUrdf(std::string protfilename, std::string robotname) {
    TemplateProtoConverter converter;
    auto protoRead = converter.loadFromFile(protfilename.c_str());
    Template *robottemp = converter.ConvertToTemplate(*protoRead);

    std::string output_file(Robot_Output_Dir + "/" + robotname + ".urdf");
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
            i++;
        }
    }

    KinNode_Part *rootpart = dynamic_cast<KinNode_Part*>(kinchain->getRoot());
    int rootindex = node2ind.find(rootpart)->second;

    // output the stl files
    separateSTLKin(protfilename, robotname, Robot_Output_Dir);

    // output the base_link
    ofs << "<link name = \"base_link\">" << std::endl;
    ofs << " <visual>" << std::endl;
    ofs << "  <origin rpy = \"0 0 0\" xyz = \"0 0 0\" />" << std::endl;
    ofs << "  <geometry>" << std::endl;
    ofs << "    <mesh filename = \"./" << robotname << rootindex << ".stl\"" << " scale = \"0.01 0.01 0.01\" />" << std::endl;
    ofs << "  </geometry> " << std::endl;
    ofs << " </visual>" << std::endl;
    ofs << "</link>" << std::endl;
    ofs << std::endl;

    // printing out the joints
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

                // Visualize parts
                ofs << "<link name = \"" << childname << "\">" << std::endl;
                ofs << " <visual>" << std::endl;
                ofs << "  <origin rpy = \"0 0 0\" xyz = \"" << -center[0] * 0.01 << " " << -center[1] * 0.01 << " " << -center[2] * 0.01 << "\" />" << std::endl;
                ofs << "  <geometry>" << std::endl;
                ofs << "    <mesh filename = \"./" << robotname << node2ind.find(childpart)->second << ".stl\"" << " scale = \"0.01 0.01 0.01\" />" << std::endl;
                ofs << "  </geometry>" << std::endl;
                ofs << " </visual>" << std::endl;
                // add collision
                ofs << " <collision>" << std::endl;
                ofs << "  <origin rpy = \"0 0 0\" xyz = \"" << -center[0] * 0.01 << " " << -center[1] * 0.01 << " " << -center[2] * 0.01 << "\" />" << std::endl;
                ofs << "  <geometry>" << std::endl;
                ofs << "    <mesh filename = \"./" << robotname << node2ind.find(childpart)->second << ".stl\"" << " scale = \"0.01 0.01 0.01\" />" << std::endl;
                ofs << "  </geometry>" << std::endl;
                ofs << " </collision>" << std::endl;
                // add physical properties (todo: mass, ix)
                ofs << " <inertial>" << std::endl;
                ofs << "  <origin rpy = \"0 0 0\" xyz = \"" << -center[0] * 0.01 << " " << -center[1] * 0.01 << " " << -center[2] * 0.01 << "\" />" << std::endl;
                ofs << "  <mass value = \"" << "1" << "\" />" << std::endl;
                ofs << "  <inertia ixx = \"" << "1" << "\" ixy = \"" << "0" << "\" ixz = \"" << "0" << "\" iyy = \"" << "1" << "\" iyz = \"" << "0" << "\" izz = \"" << "1" << "\" />" << std::endl;
                ofs << " </inertial>" << std::endl;
                ofs << "</link>" << std::endl;
                ofs << std::endl;

                // add joint
                ofs << "<joint name = \"" << parentname << "_" << childname << "\" type = \"continuous\">" << std::endl;
                ofs << "  <parent link = \"" << parentname << "\"/>" << std::endl;
                ofs << "  <child link = \"" << childname << "\"/>" << std::endl;
                ofs << "   <origin xyz = \"" << center[0] * 0.01 << " " << center[1] * 0.01 << " " << center[2] * 0.01 << "\" rpy = \"0 0 0\" />" << std::endl;
                ofs << "   <axis xyz = \"" << art->transformations[0]->axis[0] << " " << art->transformations[0]->axis[1] << " " << art->transformations[0]->axis[2] << "\" />" << std::endl;
                ofs << "</joint>" << std::endl;
                ofs << std::endl;
            }
        }
    }

    ofs << "</robot>" << std::endl;
    ofs.close();
}

