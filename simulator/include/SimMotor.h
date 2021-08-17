#ifndef EVOGEN_SIMULATOR_SIMMOTOR_H_
#define EVOGEN_SIMULATOR_SIMMOTOR_H_

#include <chrono/core/ChCoordsys.h>
#include <chrono/core/ChMathematics.h>
#include <chrono/physics/ChSystem.h>
#include <chrono/physics/ChLinkMotorRotation.h>
#include <chrono/physics/ChLinkMotorRotationTorque.h>
#include <chrono/physics/ChController.h>

#include "ChRobot.h"

class SimMotorController {
  public:
    static constexpr double pos_thresh = 1e-3;
    static constexpr double vel_P = 10;
    static constexpr double vel_I = 0.3;
    static constexpr double vel_D = 0;
    static constexpr double pos_P = 2;
    static constexpr double pos_I = 0;
    static constexpr double pos_D = 0;

    enum Mode {POSITION = 0, VELOCITY, PHASE};

    SimMotorController(const std::shared_ptr<chrono::ChLinkMotorRotationTorque>& target_motor);
    ~SimMotorController() {};

    void set_vel(double new_vel);
    void set_pos(double new_pos);
    void set_phase(double new_phase);
    void set_pid(double vp = 10, double vi = 0.3, double vd = 0,
                 double pp = 2,  double pi = 0,   double pd = 0);
    double get_torque();
    bool check_status() const;
    void set_max_pos_control_vel(double pos_ctrl_vel){ max_pos_control_vel_ = pos_ctrl_vel; }
    double get_max_torque() const { return max_torque_; }
    double get_max_vel() const { return max_vel_; }
  private:
    // the first call of pid after each reset will give an outlying output and should
    // be discarded -- this is due to pid holds no history of the last call, thus
    // there will be a bump in pid input and time stamp, both will affect the i term
    // and d term significantly. this is not a big deal in general control problem,
    // but has a big impact when we want to get the minimized max torque
    // therefore, for the first vel_pid call, we use p term only, and let go for pos_pid
    bool first_vel_pid_call_ = true;
    enum Mode mode_ = VELOCITY;
    std::shared_ptr<chrono::ChControllerPID> vel_pid_;
    std::shared_ptr<chrono::ChControllerPID> pos_pid_;
    chrono::ChLinkMotorRotationTorque *ch_motor_;

    double max_pos_control_vel_ = 3;
    double target_pos_ = 0;
    double target_vel_ = 0;
    double target_torque_ = 0;
    double max_torque_ = 0;
    double max_vel_ = 0;

};

class SimPayload {
  public:
    // with respect to the parent body frame
    void SetMass(double new_mass) { mass_ = new_mass; }
    void SetInertia(double xx, double xy, double xz, double yy, double yz, double zz);
    const std::string& GetTypeName() {return type_name_;}
    SimPayload() {};
    SimPayload(const std::string& type_name, double mass,
               double size_x, double size_y, double size_z,
               double pos_x, double pos_y, double pos_z);
    SimPayload(const std::string& type_name, const std::string& body_name, double mass,
               double size_x, double size_y, double size_z,
               double pos_x, double pos_y, double pos_z);
    ~SimPayload(){};
    void AddtoSystem(const std::shared_ptr<chrono::ChSystem>& sys) const;
    void AddtoSystem(const std::shared_ptr<chrono::ChSystem>& sys,
                     const std::shared_ptr<chrono::ChBody>& parent_body) const;

    const std::string& body_name() { return body_name_; }

  private:
    // TODO:: take a look at this body_name, might be useless
    // Also better handling the light motor!
    std::string body_name_;
    chrono::ChVector<> ch_pos_;
    chrono::ChMatrix33<> ch_inertia_ {1};
    double size_[3] = {0, 0, 0};
    double mass_ = 0;
    bool visible_ = false;
    bool check_collision_ = false;;
    std::string type_name_; ///< type name that will be sent to electronic generator
};

class SimMotor {
  public:
    // the motor is a light motor if inertial info is not set
    SimMotor(const std::string& body_name);
    // the motor will actuate the link specified by link_name, and the mass
    // of the motor will be added to the body specified by body_name
    // i.e. the motor actuating the joint between body B and C could be residing
    // on body A.
    SimMotor(const std::string& type_name, const std::string& body_name,
             const std::string& link_name, double mass,
             double size_x, double size_y, double size_z,
             double pos_x, double pos_y, double pos_z);
    // if body name is not specified, the mass will be added to the parent body
    // of the link (body 2)
    SimMotor(const std::string& type_name, const std::string& link_name,
             double mass, double size_x, double size_y, double size_z,
             double pos_x, double pos_y, double pos_z);
    ~SimMotor(){};

    void RemovePayload() { payload_.reset(); }
    void AddtoSystem(const chrono::ChRobot& robot_doc);
    void SetVel(double new_vel);
    void SetPos(double new_pos);
    void SetPhase(double new_phase);
    bool CheckStatus() const { return motor_controller_->check_status(); }
    void UpdateTorque();
    void printrot() const { std::cout << ch_motor_->GetMotorRotPeriodic() << std::endl; }

    double GetMaxTorque() const { return motor_controller_->get_max_torque(); }
    double GetMaxVel() const { return motor_controller_->get_max_vel(); }
    void SetMaxVel(double new_vel) { motor_controller_->set_max_pos_control_vel(new_vel); }
    void SetPID(double vp = 10, double vi = 0.3, double vd = 0,
                double pp = 2,  double pi = 0,   double pd = 0) {
        motor_controller_->set_pid(vp, vi, vd, pp, pi, pd);
    }

  protected:
    void add_to_system(const std::shared_ptr<chrono::ChSystem>& sys,
                       const chrono::ChLinkBodies& chlinkbody);

    std::string link_name_;
    std::shared_ptr<SimPayload> payload_; // the motor is a light motor if this pointer is null

    // Following members will be refreshed each time adding to a new system
    std::shared_ptr<SimMotorController> motor_controller_;
    std::shared_ptr<chrono::ChLinkMotorRotationTorque> ch_motor_;
    std::shared_ptr<chrono::ChFunction_Setpoint> ch_func_;
};

#endif /* end of include guard: EVOGEN_SIMULATOR_SIMMOTOR_H_ */
