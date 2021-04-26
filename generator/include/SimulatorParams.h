// SimulatorParams - Manage the params used in the simulator when generating robots
#ifndef SIMULATOR_PARAMS_H_N4TC1GM9
#define SIMULATOR_PARAMS_H_N4TC1GM9

#include <string>
#include <vector>
#include <iostream>

// TODO: load the class externally (through API or file)
class SimulatorParams {
  public:
    double time_out = 5;
    std::string env_name = "ground";
    double env_dim[3] = {5, 3, 0.01};
    double env_rot[4] = {1, 0, 0, 0}; // w, x, y, z
    bool do_viz = false;
    bool do_realtime = false;
    double camera_pos[6] = {0, -1, 1, 0, 0, 0}; // from (0, -1, 1) to (0, 0, 0)

    void SetEnv(const std::string& new_env) {env_name = new_env;}
    void AddWaypoint(double x, double y, double z);
    const std::vector<std::vector<double> >& GetWaypoints() {return waypoints_;}
    void SetCamera(double from_x, double from_y, double from_z,
                   double to_x, double to_y, double to_z);
    friend std::ostream& operator<< (std::ostream &out, const SimulatorParams& sim_params);
    bool Save(std::string filename);
    bool Load(std::string filename);

    template<class Archive>
    void serialize(Archive & ar, const unsigned int version);

  private:
    std::vector<std::vector<double> > waypoints_;
};

#endif /* end of include guard: SIMULATOR_PARAMS_H_N4TC1GM9 */
