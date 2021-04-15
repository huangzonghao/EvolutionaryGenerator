#ifndef CHURDFDOC_H_XVMVTRQF
#define CHURDFDOC_H_XVMVTRQF

#include <map>
#include <urdf_parser/urdf_parser.h>
#include <chrono/physics/ChSystemNSC.h>
#include <chrono/physics/ChSystemSMC.h>
#include <chrono/assets/ChColorAsset.h>
#include <chrono/assets/ChTexture.h>

namespace chrono {

// ChLink stores only the raw pointer of ChBodyFrame
// causing issues when fetching bodies from links
struct ChLinkBodies{
    std::shared_ptr<ChBody> body1;
    std::shared_ptr<ChBody> body2;
    std::shared_ptr<ChLink> link;
};

class ChUrdfDoc {
  public:
    ChUrdfDoc(){}
    ChUrdfDoc(const std::string& inputstring, bool inputIsString = false){
        if(inputIsString) LoadUrdfString(inputstring);
        else LoadUrdfFile(inputstring);
    }

    virtual ~ChUrdfDoc(){
        ch_materials_.clear();
        ch_link_bodies_.clear();
    };

    const std::string& GetUrdfFileName() const { return urdf_file_; }

    urdf::ModelInterfaceSharedPtr GetUrdfRobot() const { return urdf_robot_; }

    const std::shared_ptr<std::unordered_set<std::string> >& GetAuxRef() { return auxrefs_; }

    bool LoadUrdfFile(const std::string& filename);
    bool LoadUrdfString(const std::string& urdfstring);

    bool AddtoSystem(const std::shared_ptr<ChSystem>& sys, double x=0, double y=0, double z=0, double rx=0, double ry=0, double rz=0);
    bool AddtoSystem(const std::shared_ptr<ChSystem>& sys, const ChVector<>& init_pos);
    bool AddtoSystem(const std::shared_ptr<ChSystem>& sys, const ChCoordsys<>& init_coord);
    bool AddtoSystem(const std::shared_ptr<ChSystem>& sys, const std::shared_ptr<ChBody>& init_pos_body);

    const std::shared_ptr<chrono::ChSystem> GetSystem() const { return ch_system_; }

    const std::string& GetRobotName() const { return urdf_robot_->getName(); }

    const ChLinkBodies& GetLinkBodies(const std::string& name) const;

    std::shared_ptr<ChBody> GetRootBody() const { return ch_root_body_; }
    std::shared_ptr<ChBody> GetCameraBody() const { return GetRootBody(); }

    double GetRootMass() const { return ch_root_body_->GetMass(); }

    const std::string& GetLinkBodyName(const std::string& link_name, int body_idx);

    void SetCollisionMaterial(const std::shared_ptr<ChMaterialSurfaceNSC>& new_mat){ collision_material_ = new_mat; }

    std::shared_ptr<std::vector<std::shared_ptr<ChBody> > >& GetBodyList() {return body_list_;}

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
    std::string urdf_file_;
    std::string urdf_string_;
    urdf::ModelInterfaceSharedPtr urdf_robot_;
    urdf::LinkConstSharedPtr u_root_link_;
    std::shared_ptr<chrono::ChSystem> ch_system_;
    std::map<std::string, ChMatPair> ch_materials_;
    std::map<std::string, ChLinkBodies> ch_link_bodies_;
    std::shared_ptr<ChBody> ch_root_body_;
    std::shared_ptr<ChMaterialSurfaceNSC> collision_material_;
    // names of bodies that would use ChBodyAuxRef
    std::shared_ptr<std::unordered_set<std::string> > auxrefs_;

    std::shared_ptr<std::vector<std::shared_ptr<ChBody> > > body_list_;
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
