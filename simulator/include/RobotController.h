#ifndef ROBOTCONTROLLER_H_WU5YVSBW
#define ROBOTCONTROLLER_H_WU5YVSBW

#include <chrono/core/ChMathematics.h>
#include <chrono/physics/ChBody.h>

#include "SimMotor.h"

class RobotController {
  public:
    enum ControllerType {MANIPULATOR, WHEEL, LEGGED} type;

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

    WheelController(std::vector<std::shared_ptr<SimMotor> > *motors,
                    std::vector<chrono::ChVector<> > *waypoints,
                    const std::shared_ptr<chrono::ChBody>& ch_body)
        : RobotController(motors, waypoints, WHEEL), robot_body(ch_body.get()){}

    ~WheelController(){};

    chrono::ChBody *robot_body;

    bool Update() override;

  private:
    enum GAITS {FORWARD, BACKWARD, LEFT1, RIGHT1, LEFT2, RIGHT2} gait;
    void exe_gait();

};

#endif /* end of include guard: ROBOTCONTROLLER_H_WU5YVSBW */
