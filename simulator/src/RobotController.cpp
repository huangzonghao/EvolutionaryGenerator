#include "RobotController.h"

RobotController::
RobotController(std::vector<std::shared_ptr<SimMotor> > *motors, ControllerType type)
    : motors_(motors), type(type) {}

RobotController::RobotController(std::vector<std::shared_ptr<SimMotor> > *motors,
                                 std::vector<chrono::ChVector<> > *waypoints,
                                 ControllerType type)
    : motors_(motors), waypoints_(waypoints), type(type) {}

WheelController::WheelController(std::vector<std::shared_ptr<SimMotor> > *motors)
    : RobotController(motors, WHEEL)
{
    for (auto& motor : *motors_) {
        motor->SetPID(1, 0, 0, 1, 0, 0);
        motor->SetMaxVel(1);
    }
}

bool WheelController::Update(){
    gait = FORWARD;
    exe_gait();
    for (auto& motor : *motors_)
        motor->UpdateTorque();

    return false;
}

void WheelController::exe_gait(){
    // negative vel moves the robot forward
    switch(gait){
    case FORWARD:
        for (auto& motor : *motors_)
            motor->SetVel(-6);
        break;
    case BACKWARD:
        for (auto& motor : *motors_)
            motor->SetVel(6);
        break;
    }
}

void LegController::SetMotors(const std::vector<std::shared_ptr<SimMotor> >& motors) {
    motors_ = motors;
}

void LegController::exe_gait(size_t gait_id) {
    switch(motors_.size()) {
    case 1:
        exe_gait1(gait_id);
        break;
    case 2:
        exe_gait2(gait_id);
        break;
    case 3:
        exe_gait3(gait_id);
        break;
    default:
        std::cout << "Error: Incorrect number of motors in leg" << std::endl;
        exit(EXIT_FAILURE);
    }
}

void LegController::exe_gait1(size_t gait_id) {
    motors_[0]->SetVel(3);
    // switch (gait_id) {
    // case 0:
        // motors_[0]->SetPhase(0);
        // break;
    // case 1:
        // motors_[0]->SetPhase(-0.3);
        // break;
    // case 2:
        // motors_[0]->SetPhase(0.3);
        // break;
    // }
}

void LegController::exe_gait2(size_t gait_id) {
    switch (gait_id) {
    case 0: // still
        motors_[0]->SetPhase(-0.4);
        motors_[1]->SetPhase(0.8);
        break;
    case 1: // forward
        motors_[0]->SetPhase(-0.9);
        motors_[1]->SetPhase(1.3);
        break;
    case 2: // backward
        motors_[0]->SetPhase(0.4);
        motors_[1]->SetPhase(0.4);
        break;
    }
}

void LegController::exe_gait3(size_t gait_id) {
    switch (gait_id) {
    case 0: // still
        motors_[0]->SetPhase(-0.3);
        motors_[1]->SetPhase(0.5);
        motors_[2]->SetPhase(0.4);
        break;
    case 1: // forward
        motors_[0]->SetPhase(-0.8);
        motors_[1]->SetPhase(0.8);
        motors_[2]->SetPhase(0.8);
        break;
    case 2: // backward
        motors_[0]->SetPhase(0.3);
        motors_[1]->SetPhase(0.2);
        motors_[2]->SetPhase(0.2);
        break;
    }
}

void EvoGenController::SetLegs(const std::vector<std::vector<std::shared_ptr<SimMotor> > >& leg_motors) {
    legs_.clear();
    legs_.resize(leg_motors.size());
    for (int i = 0; i < leg_motors.size(); ++i) {
        legs_[i].SetMotors(leg_motors[i]);
    }
}

bool EvoGenController::Update() {
    // make sure all the motors have moved to the right place
    gait_lock = false;
    for (auto& motor : *motors_){
        motor->UpdateTorque();
        // check whether every motor arrived at target pos
        gait_lock |= !motor->CheckStatus();
    }
    if (gait_lock){
        // TODO: why do I need this.
        if (update_counter_++ < 600)
            return false;
        update_counter_ = 0;
    }

    switch (legs_.size()) {
    case 4:
        // Four: FL, BL, BR, FR
        switch (gait_) {
        case 0:
            legs_[0].exe_gait(0);
            legs_[1].exe_gait(0);
            legs_[2].exe_gait(0);
            legs_[3].exe_gait(0);
            gait_ = 1;
            break;
        case 1:
            legs_[0].exe_gait(2);
            legs_[1].exe_gait(1);
            legs_[2].exe_gait(2);
            legs_[3].exe_gait(1);
            gait_ = 2;
            break;
        case 2:
            legs_[0].exe_gait(1);
            legs_[1].exe_gait(2);
            legs_[2].exe_gait(1);
            legs_[3].exe_gait(2);
            gait_ = 1;
            break;
        }
        break;
    case 6:
        // Six:  FL, ML, BL, BR, MR, FR
        switch (gait_) {
        case 0:
            legs_[0].exe_gait(0);
            legs_[1].exe_gait(0);
            legs_[2].exe_gait(0);
            legs_[3].exe_gait(0);
            legs_[4].exe_gait(0);
            legs_[5].exe_gait(0);
            gait_ = 1;
            break;
        case 1:
            legs_[0].exe_gait(2);
            legs_[1].exe_gait(1);
            legs_[2].exe_gait(2);
            legs_[3].exe_gait(1);
            legs_[4].exe_gait(2);
            legs_[5].exe_gait(1);
            gait_ = 2;
            break;
        case 2:
            legs_[0].exe_gait(1);
            legs_[1].exe_gait(2);
            legs_[2].exe_gait(1);
            legs_[3].exe_gait(2);
            legs_[4].exe_gait(1);
            legs_[5].exe_gait(2);
            gait_ = 1;
            break;
        }
        break;
    default:
        std::cout << "Error: Wrong number of legs in controller" << std::endl;
        exit(EXIT_FAILURE);
    }

    return false;
}
