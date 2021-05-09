#include "RobotController.h"

RobotController::
RobotController(std::vector<std::shared_ptr<SimMotor> > *motors, ControllerType type):
    motors_(motors), type(type){}

RobotController::RobotController(std::vector<std::shared_ptr<SimMotor> > *motors,
                                 std::vector<chrono::ChVector<> > *waypoints,
                                 ControllerType type):
    motors_(motors), waypoints_(waypoints), type(type){}

bool WheelController::Update(){
    // if ((robot_body->GetPos() - waypoints_->at(waypoint_idx)).Length() < 2){
        // if (waypoint_idx < waypoints_->size() - 1){
            // ++waypoint_idx;
        // }
        // else {
            // return true;
        // }
    // }

    // chrono::ChVector<> goal_local =
        // robot_body->TransformPointParentToLocal(waypoints_->at(waypoint_idx));

    // double yx_ratio = goal_local.y() / (goal_local.x() + 1e-8); // in case x is zero

    // // the head of robot is pointing +x
    // if (yx_ratio > 0.33){
        // gait = LEFT2;
    // }
    // else if (yx_ratio < -0.33){
        // gait = RIGHT2;
    // }
    // else{
        // if (goal_local.x() > 0){
            // gait = FORWARD;
        // }
        // else {
            // gait = BACKWARD;
        // }
    // }

    gait = FORWARD;

    exe_gait();

    for (auto motor : *motors_){
        motor->UpdateTorque();
    }

    return false;
}

void WheelController::exe_gait(){
    // if (motors_->size() < 4){
        // std::cerr << "Error from RobotController: Motor insufficient" << std::endl;
    // }
    // motor 0 1 left, 2 3 right
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
        case RIGHT1:
            motors_->at(0)->SetVel(-6);
            motors_->at(1)->SetVel(-6);
            motors_->at(2)->SetVel(6);
            motors_->at(3)->SetVel(6);
            break;
        case LEFT1:
            motors_->at(0)->SetVel(6);
            motors_->at(1)->SetVel(6);
            motors_->at(2)->SetVel(-6);
            motors_->at(3)->SetVel(-6);
            break;
        case RIGHT2:
            motors_->at(0)->SetVel(-6);
            motors_->at(1)->SetVel(-6);
            motors_->at(2)->SetVel(6);
            motors_->at(3)->SetVel(6);
            break;
        case LEFT2:
            motors_->at(0)->SetVel(6);
            motors_->at(1)->SetVel(6);
            motors_->at(2)->SetVel(-6);
            motors_->at(3)->SetVel(-6);
            break;
    }
}
