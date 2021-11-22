// This class is temporarily used as a variable container,
// but is meant to merge together and replace SimulatorParams and EvoParams
#ifndef EVOGEN_GENERATOR_INCLUDE_TRAININGCONFIGS_H_
#define EVOGEN_GENERATOR_INCLUDE_TRAININGCONFIGS_H_

#include <string>
#include <vector>

class EvoGenTrainingConfigs {
  public:
    // Evolution
    int num_gen() { return num_gen_; }
    void set_num_gen(int new_num_gen) { num_gen_ = new_num_gen; }
    int pop_size() { return pop_size_; }
    void set_pop_size(int new_pop_size) { pop_size_ = new_pop_size; }

    // Simulation
    const std::string& env() { return env_; }
    void set_env(const std::string& new_env) { env_ = new_env; }
    double sim_time() { return sim_time_; }
    void set_sim_time(double new_sim_time) { sim_time_ = new_sim_time; }

    // Book keeping
    const std::string& output_dir() { return output_dir_; }
    void set_output_dir(const std::string& new_output_dir) { output_dir_ = new_output_dir; }

  private:
    int num_gen_ = 0;
    int pop_size_ = 0;
    double sim_time_ = 0;
    std::string env_ = "";
    std::string output_dir_ = "";
};

#endif /* end of include guard: EVOGEN_GENERATOR_INCLUDE_TRAININGCONFIGS_H_ */