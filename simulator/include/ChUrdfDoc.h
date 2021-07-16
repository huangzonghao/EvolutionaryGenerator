#ifndef CHURDFDOC_H_XVMVTRQF
#define CHURDFDOC_H_XVMVTRQF

#include <map>
#include <urdf_parser/urdf_parser.h>
#include <chrono/physics/ChSystemNSC.h>
#include <chrono/physics/ChSystemSMC.h>
#include <chrono/assets/ChColorAsset.h>
#include <chrono/assets/ChTexture.h>

#include "ChRobot.h"

namespace chrono {

class ChUrdfDoc : public ChRobot {
  public:
    ChUrdfDoc(){}
    ChUrdfDoc(const std::string& inputstring, bool inputIsString = false){
        if(inputIsString) LoadRobotString(inputstring);
        else LoadRobotFile(inputstring);
    }

    virtual ~ChUrdfDoc(){ ch_materials_.clear(); };

    bool LoadRobotFile(const std::string& filename) override;
    bool LoadRobotString(const std::string& urdfstring) override;

    bool AddtoSystem(const std::shared_ptr<ChSystem>& sys, const ChCoordsys<>& init_coord) override;
    bool AddtoSystem(const std::shared_ptr<ChSystem>& sys, const std::shared_ptr<ChBody>& init_pos_body);

    urdf::ModelInterfaceSharedPtr GetUrdfRobot() const { return urdf_robot_; }
    const std::string& GetRobotName() const override { return urdf_robot_->getName(); }

    void SetCollisionMaterial(const std::shared_ptr<ChMaterialSurfaceNSC>& new_mat){ collision_material_ = new_mat; }

  private:
    struct ChMatPair{
        std::shared_ptr<ChColor> color;
        std::shared_ptr<ChTexture> texture;
    };

    const ChMatPair& GetMaterial(const std::string& name) {
        return ch_materials_.find(name)->second;
    }

    bool color_empty(const urdf::Color& test_color);
    std::string urdf_abs_path(const std::string& relative_path);
    std::shared_ptr<ChBody> convert_links(const urdf::LinkConstSharedPtr& u_link,
                                          const std::shared_ptr<ChBody>& ch_parent_body);

    std::shared_ptr<ChLinkLock> process_joints(const urdf::JointConstSharedPtr& u_joint,
                                               const std::shared_ptr<ChBody>& ch_parent_body,
                                               const std::shared_ptr<ChBody>& ch_child_body);
    void convert_materials();
    bool check_inertial_pose_set(const urdf::LinkConstSharedPtr& u_link);
    // concatenates the urdf flie path and the relative path to the urdf file
    urdf::ModelInterfaceSharedPtr urdf_robot_;
    urdf::LinkConstSharedPtr u_root_link_;
    std::map<std::string, ChMatPair> ch_materials_;
    std::shared_ptr<ChMaterialSurfaceNSC> collision_material_;
    std::shared_ptr<std::vector<std::shared_ptr<ChBody>>> body_list_;
};

// torque functor for a rot spring with constant spring coefficient and constant damping coefficient
class RotSpringConstDampingTorque : public ChLinkRotSpringCB::TorqueFunctor {
  public:
    RotSpringConstDampingTorque(double spring_coef, double damping_coef) : spring_coef(spring_coef), damping_coef(damping_coef){}

    virtual double operator()(double time,             // current time
                              double angle,            // relative angle of rotation
                              double vel,              // relative angular speed
                              ChLinkRotSpringCB* link  // back-pointer to associated link
                              ) override {
        return -spring_coef * angle - damping_coef * vel;
    }
  private:
    double spring_coef;
    double damping_coef;
};

}  // END_OF_NAMESPACE_

#endif /* end of include guard: CHURDFDOC_H_XVMVTRQF */
