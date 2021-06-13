#ifndef ROBOTCONTROLLER_H_WU5YVSBW
#define ROBOTCONTROLLER_H_WU5YVSBW

#include <vector>
#include <chrono/core/ChMathematics.h>
#include <chrono/physics/ChBody.h>

#include "SimMotor.h"

class RobotController {
  public:
    enum ControllerType {MANIPULATOR = 0, WHEEL, LEGGED, EVOGEN} type;

    RobotController(std::vector<std::shared_ptr<SimMotor> > *motors, ControllerType type);
    RobotController(std::vector<std::shared_ptr<SimMotor> > *motors,
                    std::vector<chrono::ChVector<> > *waypoints,
                    ControllerType type);
    virtual ~RobotController() = default;
    virtual bool Update() = 0;
  protected:
    bool gait_lock = false;
    int waypoint_idx = 0;
    std::vector<std::shared_ptr<SimMotor> > *motors_;
    std::vector<chrono::ChVector<> > *waypoints_;
};

class WheelController : public RobotController {
  public:
    WheelController(std::vector<std::shared_ptr<SimMotor> > *motors)
        : RobotController(motors, WHEEL){}
    ~WheelController(){};
    bool Update() override;
  private:
    enum GAITS {FORWARD = 0, BACKWARD, LEFT1, RIGHT1, LEFT2, RIGHT2} gait;
    void exe_gait();
};

class LegController {
  public:
    void SetMotors(const std::vector<std::shared_ptr<SimMotor> >& motors);
    void exe_gait(size_t gait_id);
  private:
    std::vector<std::shared_ptr<SimMotor> > motors_;
    void exe_gait1(size_t gait_id);
    void exe_gait2(size_t gait_id);
    void exe_gait3(size_t gait_id);
};

class EvoGenController : public RobotController {
  public:
    EvoGenController(std::vector<std::shared_ptr<SimMotor> > *motors)
        : RobotController(motors, EVOGEN) {}
    virtual bool Update() override;
    void SetLegs(const std::vector<std::vector<std::shared_ptr<SimMotor> > >& leg_motors);
  private:
    size_t update_counter_ = 0; // TODO: remove this
    size_t gait_ = 0;
    // TODO: now *motors and motors in leg are passed in seperately
    // Order of legs:
    //     Four: FL, BL, BR, FR
    //     Six:  FL, ML, BL, BR, MR, FR
    std::vector<LegController> legs_;
};

#endif /* end of include guard: ROBOTCONTROLLER_H_WU5YVSBW */
