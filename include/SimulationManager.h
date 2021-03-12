#ifndef SIMULATIONMANAGER_H_TQPVGDZV
#define SIMULATIONMANAGER_H_TQPVGDZV

#include "chrono/physics/ChSystem.h"
#include "ChUrdfDoc.h"
#include <Eigen/Core>

class  SimulationManager {
  public:

    enum SystemType {NSC, SMC};

    SimulationManager(double step_size=0.005,
                      double timeout=50,
                      double system_friction_k=1.9,
                      double system_friction_s=2.0,
                      SystemType system_type=NSC);

    ~SimulationManager(){
        ch_waypoints_.clear();
    }

    void SetSystemType(SystemType new_type) {system_type_ = new_type;}
    void SetUrdfFile(std::string filename);
    void DisableEnv() {load_map_ = false;}
    // force user to input xyz dimension of the map, especially for bmp and urdf maps
    void SetEnv(std::string filename, double env_x, double env_y, double env_z);
    // TODO: should be done within SetEnv, but currently having difficulty readin bitmap in c++
    void SetEigenHeightmap(const std::shared_ptr<const Eigen::MatrixXd>& heightmap);
    void SetFrictionS(double fs) {s_friction_ = fs;};
    void SetFrictionK(double fk) {k_friction_ = fk;};
    void SetTimeout(double timeout) {timeout_ = timeout;};

    void AddWaypoint(double x, double y, double z);
    void AddWaypoints(const std::shared_ptr<const Eigen::MatrixXd>& waypoints_ptr);
    bool RunSimulation(bool do_viz=true, bool do_realtime=false);
    const std::string& GetUrdfFileName();

  private:
    // map is enabled as flat ground by default.
    bool load_map_ = true;
    void load_map();
    SystemType  system_type_;
    double k_friction_;
    double s_friction_;

    std::vector<chrono::ChVector<> > ch_waypoints_;
    std::shared_ptr<chrono::ChUrdfDoc> urdf_doc_;
    std::shared_ptr<const Eigen::MatrixXd> eigen_waypoints_;
    std::shared_ptr<chrono::ChSystem> ch_system_;
    std::shared_ptr<const Eigen::MatrixXd> heightmap_;

    bool task_done_ = false;
    double step_size_;
    double timeout_;

    std::string env_file_;
    // unit: m
    double env_x_ = 1;
    double env_y_ = 1;
    double env_z_ = 0.08;
};

#endif /* end of include guard: SIMULATIONMANAGER_H_TQPVGDZV */
