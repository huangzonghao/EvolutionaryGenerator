#ifndef EVOGEN_SIMULATOR_SIMULATIONMANAGER_H_
#define EVOGEN_SIMULATOR_SIMULATIONMANAGER_H_

#include <Eigen/Core>
#include <chrono/physics/ChSystem.h>

#include "SimMotor.h"
#include "RobotController.h"
#include "ChRobot.h"

class  SimulationManager {
  public:
    enum SystemType {NSC, SMC};
    enum ControllerType {Dummy = 0, Wheel, EvoGen};

    SimulationManager(double step_size=0.005,
                      double timeout=50,
                      double system_friction_k=1.9,
                      double system_friction_s=2.0,
                      SystemType system_type=NSC);

    ~SimulationManager(){
        payloads_.clear();
        motors_.clear();
        ch_waypoints_.clear();
        auxrefs_.reset();
    }

    void SetSystemType(SystemType new_type) {system_type_ = new_type;}
    void LoadUrdfFile(const std::string& filename);
    void LoadUrdfString(const std::string& urdfstring);
    // void LoadRobogamiProtoFile(const std::string& filename);
    // void LoadRobogamiRobot();
    void DisableEnv() {load_map_ = false;}
    // force user to input xyz dimension of the map, especially for bmp and urdf maps
    // use "ground" for the default flat ground
    void SetEnv(const std::string& filename, double env_x, double env_y, double env_z);
    void SetEnvRot(double w, double x, double y, double z) { env_rot_ = chrono::ChQuaternion<>(w, x, y, z); }
    // TODO: should be done within SetEnv, but currently having difficulty readin bitmap in c++
    void SetEigenHeightmap(const std::shared_ptr<const Eigen::MatrixXd>& heightmap);
    void SetFrictionS(double fs) {s_friction_ = fs;};
    void SetFrictionK(double fk) {k_friction_ = fk;};
    void SetTimeout(double timeout) {timeout_ = timeout;};

    void AddComponent(const std::string& type_name, const std::string& body_name,
                      double mass, double size_x, double size_y, double size_z,
                      double pos_x=0, double pos_y=0, double pos_z=0);
    void AddMotor(const std::string& type_name, const std::string& body_name,
                  const std::string& link_name, double mass,
                  double size_x, double size_y, double size_z,
                  double pos_x=0, double pos_y=0, double pos_z=0);
    void AddEvoGenMotor(const std::string& link_name, size_t leg_id, size_t link_id);
    void AddWaypoint(double x, double y, double z);
    void AddWaypoints(const std::shared_ptr<const Eigen::MatrixXd>& waypoints_ptr);
    void RemoveLastMotor();
    void RemoveAllMotors();
    void SetController(ControllerType controller_type = EvoGen) { controller_type_ = controller_type; }

    const std::shared_ptr<SimMotor> GetMotor(int motor_idx) const { return motors_[motor_idx];}

    void SetCamera(std::vector<double> camera_pos);
    void SetCamera(double from_x, double from_y, double from_z,
                   double to_x, double to_y, double to_z);
    void SetLight(std::vector<double> camera_pos);
    void SetLight(double x, double y, double z);
    void SetFOV(double fov);
    void SetVisualization(bool do_viz=true) { do_viz_ = do_viz; }
    void SetRealTime(bool do_realtime=true) { do_realtime_ = do_realtime; }
    void SetCanvasSize(int width, int height) { canvas_size_[0] = width; canvas_size_[1] = height; }
    void SetCanvasSize(std::vector<int> canvas_size) { SetCanvasSize(canvas_size[0], canvas_size[1]); }
    void SetRobotColor(std::vector<double> robot_color);
    void SetEnvColor(std::vector<double> env_color);
    void RecordVideoFrames(int frame_interval, const std::string& output_name=""); // set frame_interval = -1 to disable

    bool RunSimulation();
    const std::string& GetUrdfFileName();

    double GetLastSimTime() { return last_sim_time_; }
    bool CheckRobotSelfCollision() { return robot_self_collided_; }

    /** Interface functions **/
    void GetActuatorVels(std::vector<std::pair<double, double>> &vels_vec) const;
    void GetActuatorTorques(std::vector<std::pair<double, double>> &torqs_vec) const;
    size_t GetMotorNumber() const { return motors_.size(); }
    size_t GetComponentNumber() const { return motors_.size() + payloads_.size(); }
    double GetRootBodyDisplacement() const;
    double GetRootBodyDisplacementX() const;
    double GetRootBodyDisplacementY() const;
    double GetRootBodyAccumulatedY() const;
    void EnableEarlyTermination() { early_termination_enabled_ = true; }
  private:
    ControllerType controller_type_ = EvoGen;
    // map is enabled as flat ground by default.
    bool load_map_ = true;
    void load_map();
    bool early_termination_enabled_ = false;
    bool check_termination();
    double fall_down_thresh = 0;
    SystemType  system_type_;
    double k_friction_;
    double s_friction_;
    bool robot_self_collided_ = false;

    // Statics collected in training
    void init_stats();
    void update_stats();
    double accumulated_y_= 0;
    double prev_y_= 0;

    std::vector<std::shared_ptr<SimPayload>> payloads_;
    std::vector<std::shared_ptr<SimMotor>> motors_;
    std::vector<chrono::ChVector<>> ch_waypoints_;
    std::shared_ptr<chrono::ChRobot> robot_doc_;
    std::shared_ptr<const Eigen::MatrixXd> eigen_waypoints_;
    // we need to keep ch_system_ outside of RunSimulation in case we need to get any
    // post simulation information
    std::shared_ptr<chrono::ChSystem> ch_system_;
    std::shared_ptr<const Eigen::MatrixXd> heightmap_;

    bool task_done_ = false;
    bool do_viz_ = true;
    bool do_realtime_ = false;
    double step_size_;
    double timeout_;
    double camera_pos_[6] = {0, -1, 1, 0, 0, 0}; // from (0, -1, 1) to (0, 0, 0)
    double light_pos_[3] = {0, 0, -1}; // three numbers specify the direction of the light
    double fov_ = 45; // field of view in degrees
    double canvas_size_[2] = {1280, 720};
    double robot_color_[4] = {0, 0, 0, 0}; // enable, r, g, b
    double env_color_[3] = {0.2, 0.2, 0.2}; // r, g, b
    bool save_video_frames_ = false;
    int video_frame_interval_ = 20; // Video renedred at 200 Hz with step_size_ == 0.005
    int video_frame_counter_ = 0;
    std::string video_frame_output_name_;

    std::string env_file_;
    // unit: m
    double env_x_ = 1;
    double env_y_ = 1;
    double env_z_ = 0.08;
    chrono::ChQuaternion<> env_rot_ = chrono::QUNIT;

    double displacement_ = 0;
    size_t num_legs_ = 0;
    std::vector<std::vector<std::shared_ptr<SimMotor>>> leg_motors_;

    // names of bodies that would use ChBodyAuxRef
    // this pointer is initialized when a urdf file has been loaded
    std::shared_ptr<std::unordered_set<std::string>> auxrefs_;

    double last_sim_time_ = 0;
};

#endif /* end of include guard: EVOGEN_SIMULATOR_SIMULATIONMANAGER_H_ */
