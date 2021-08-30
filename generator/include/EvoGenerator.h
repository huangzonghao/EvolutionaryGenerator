#ifndef EVOGEN_GENERATOR_EVOGENERATOR_H_
#define EVOGEN_GENERATOR_EVOGENERATOR_H_

#include <string>
#include "SimulatorParams.h"
#include "EvoParams.h"

class EvoGenerator {
  public:
    void set_evo_params(const EvoParams& evo_params) { evo_params_ = evo_params; }
    void set_sim_params(const SimulatorParams& sim_params) { sim_params_ = sim_params; }
    void set_result_dir(const std::string& res_dir) { res_dir_ = res_dir; }
    void set_user_seeds(const std::shared_ptr<std::vector<std::vector<double>>>& new_seeds) { user_seeds_ = new_seeds; }
    void run();
    void resume(const std::string& res_dir, int dump_gen_id);
  private:
    EvoParams evo_params_;
    SimulatorParams sim_params_;
    std::string res_dir_;
    std::shared_ptr<std::vector<std::vector<double>>> user_seeds_;
};

#endif /* end of include guard: EVOGEN_GENERATOR_EVOGENERATOR_H_ */
