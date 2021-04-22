// SimulatorParams - Manage the params used in the simulator when generating robots
#ifndef SIMULATOR_PARAMS_H_N4TC1GM9
#define SIMULATOR_PARAMS_H_N4TC1GM9

#include <string>
#include <vector>

// TODO: load the class externally (through API or file)
class SimulatorParams {
  public:
    double time_out = 5;
    std::string env_name = "ground";
    double env_dim[3] = {5, 3, 0.01};
    bool do_viz = false;
    bool do_realtime = false;

    void SetEnv(const std::string& new_env);
    void AddWaypoint(double x, double y, double z);
    const std::vector<std::vector<double> >& GetWaypoints() {return waypoints_;};

  private:
    std::vector<std::vector<double> > waypoints_;
};

#endif /* end of include guard: SIMULATOR_PARAMS_H_N4TC1GM9 */
