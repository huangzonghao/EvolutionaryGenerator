#ifndef EVOGEN_SIMULATOR_CHROBOT_H_
#define EVOGEN_SIMULATOR_CHROBOT_H_

#include <chrono/core/ChCoordsys.h>
#include <chrono/physics/ChSystem.h>

#include "ChLinkBodies.h"

// Base class for Mechanical Representation of Robots
namespace chrono {

class ChRobot {
  public:
    ~ChRobot(){ ch_link_bodies_.clear(); };
    virtual bool LoadRobotFile(const std::string& robotfile) = 0;
    virtual bool LoadRobotString(const std::string& robotstring) = 0;

    virtual bool AddtoSystem(const std::shared_ptr<ChSystem>& sys, const ChCoordsys<>& init_coord) = 0;
    bool AddtoSystem(const std::shared_ptr<ChSystem>& sys,
                     double x = 0, double y = 0, double z = 0,
                     double rx = 0, double ry = 0, double rz = 0) {
        return AddtoSystem(sys, ChCoordsys<>(ChVector<>(x, y, z), Q_from_Euler123(ChVector<>(rx, ry, rz))));
    }
    bool AddtoSystem(const std::shared_ptr<ChSystem>& sys, const ChVector<>& init_pos) {
        return AddtoSystem(sys, ChCoordsys<>(init_pos, QUNIT));
    }

    virtual const std::string& GetRobotName() const = 0;
    virtual const std::string& GetRobotFileName() const { return robot_file_; }
    void SetAuxRef(const std::shared_ptr<std::unordered_set<std::string>>& auxrefs) { auxrefs_ = auxrefs; }
    const std::shared_ptr<std::unordered_set<std::string>>& GetAuxRef() { return auxrefs_; }
    const std::shared_ptr<chrono::ChSystem> GetSystem() const { return ch_system_; }
    const ChLinkBodies& GetLinkBodies(const std::string& link_name) const {
        if (ch_link_bodies_.find(link_name) == ch_link_bodies_.end()){
            std::cerr << "Error: robot " << GetRobotName() << " doesn't contain link " << link_name << std::endl;
            exit(EXIT_FAILURE);
        }
        return ch_link_bodies_.at(link_name);
        // return ch_link_bodies_.find(link_name)->second;
    }
    std::shared_ptr<ChBody> GetRootBody() const { return ch_root_body_; }
    std::shared_ptr<ChBody> GetCameraBody() const { return GetRootBody(); }
    double GetRootMass() const { return ch_root_body_->GetMass(); }

    // TODO: only min_pos_z and footprint of feet are captured correctly for now
    const chrono::ChVector<>& GetMaxPos() const {return max_pos_;}
    const chrono::ChVector<>& GetMinPos() const {return min_pos_;}
    chrono::ChVector<> GetBBoxSize() const {return max_pos_ - min_pos_;}


  protected:
    std::string robot_file_;
    std::string robot_string_;
    std::shared_ptr<chrono::ChSystem> ch_system_;
    std::map<std::string, ChLinkBodies> ch_link_bodies_;
    std::shared_ptr<ChBody> ch_root_body_;
    // names of bodies that would use ChBodyAuxRef
    std::shared_ptr<std::unordered_set<std::string>> auxrefs_;
    chrono::ChVector<> max_pos_ = {std::numeric_limits<double>::lowest()};
    chrono::ChVector<> min_pos_ = {std::numeric_limits<double>::max()};
};

} // namespace chrono

#endif /* end of include guard: EVOGEN_SIMULATOR_CHROBOT_H_ */
