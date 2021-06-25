#ifndef CHROBOGAMI_H_CEIYORBT
#define CHROBOGAMI_H_CEIYORBT

#include <map>
#include <chrono/physics/ChSystemNSC.h>
#include <chrono/physics/ChSystemSMC.h>
#include <FBE_Kinematics/KinChain.h>
#include <FBE_Temp/template.h>
#include <FBE_Temp/geometry.h>

#include "ChRobot.h"

namespace chrono {

class ChRobogami : public ChRobot {
  public:
    ChRobogami(){}
    ChRobogami(const std::string& proto_file){ LoadRobotFile(proto_file); }

    bool LoadRobotFile(const std::string& protofile) override;
    bool LoadRobotString(const std::string& robotstring) { return false; };
    bool LoadRobotTemplate(const std::shared_ptr<FabByExample::Template>& robot_template);
    bool AddtoSystem(const std::shared_ptr<ChSystem>& sys, const ChCoordsys<>& init_coord) override;
    const std::string& GetRobotName() const override { return robot_name_; }

  private:
    std::string robot_name_ = "Robogami_Temp";
    std::shared_ptr<FabByExample::Template> template_;
};

}  // namespace chrono

#endif /* end of include guard: CHROBOGAMI_H_CEIYORBT */
