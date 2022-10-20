// This class is temporarily used as a variable container,
// but is meant to merge together and replace SimulatorParams and EvoParams
#ifndef EVOGEN_GENERATOR_INCLUDE_TRAININGCONFIGS_H_
#define EVOGEN_GENERATOR_INCLUDE_TRAININGCONFIGS_H_

#include <string>
#include <vector>
#include <iostream>

class EvoGenTrainingConfigs {
  public:
    enum UserDesignSampling { ALL = 0, RANDOM };

    // Evolution
    int num_gen() { return num_gen_; }
    void set_num_gen(int new_num_gen) { num_gen_ = new_num_gen; }
    int init_pop_size() { return init_pop_size_; }
    void set_init_pop_size(int new_size) { init_pop_size_ = new_size; }
    int pop_size() { return pop_size_; }
    void set_pop_size(int new_size) { pop_size_ = new_size; }
    int num_user_inputs() { return num_user_inputs_; }
    void set_num_user_inputs(int new_size) { num_user_inputs_ = new_size; }
    std::vector<int>& grid_dim() { return grid_dim_; }
    void set_grid_dim(const std::vector<int>& grid_dim) { grid_dim_ = grid_dim; }
    EvoGenTrainingConfigs::UserDesignSampling user_design_sampling() { return input_sampling_; }
    const std::string& evaluator() { return evaluator_; }
    void set_user_design_sampling(enum UserDesignSampling input_sampling) { input_sampling_ = input_sampling; }
    void set_evaluator(const std::string& evaluator) { evaluator_ = evaluator; }

    // Simulation
    const std::string& env() { return env_; }
    void set_env(const std::string& new_env) { env_ = new_env; }
    double sim_time() { return sim_time_; }
    void set_sim_time(double new_sim_time) { sim_time_ = new_sim_time; }

    // Book keeping
    const std::string& output_dir() { return output_dir_; }
    void set_output_dir(const std::string& new_output_dir) { output_dir_ = new_output_dir; }

    bool save(const std::string& filename) const;
    bool load(const std::string& filename);

    // Newly added
    size_t rand_seed() const { return rand_seed_; }
    void set_rand_seed(size_t new_seed) { rand_seed_ = new_seed; }
    const size_t rand_seed() const { return rand_seed_; }
    const int init_size() const { return init_size_; }
    void set_init_size(int new_init_size) { init_size_ = new_init_size; }
    const int progress_dump_period() const { return progress_dump_period_; }
    void set_progress_dump_period(int new_period) { progress_dump_period_ = new_period; }
    const int output_write_period() const { return output_write_period_; }
    void set_output_write_period(int new_period) { output_write_period_ = new_period; }
    const bool output_all_robots() const { return output_all_robots_; }
    void set_output_all_robots(bool enable_robot_output) { output_all_robots_ = enable_robot_output; }
    const double phen_data_min() const { return phen_data_min_; }
    void set_phen_data_min(double new_min) { phen_data_min_ = new_min; }
    const double phen_data_max() const { return phen_data_max_; }
    void set_phen_data_max(double new_max) { phen_data_max_ = new_max; }
    const std::vector<int>& grid_shape() const { return grid_shape_; }
    void set_grid_shape(const std::vector<int>& grid_shape) { grid_shape_ = grid_shape; }
    bool output_enabled() const { return enable_output_; }
    void set_output(bool enable_output) { enable_output_ = enable_output; }

    std::vector<std::string>& feature_description() { return feature_description_; }
    bool set_feature_description(const char* const* descriptor_names) {
        feature_description_.clear();
        feature_description_.resize(grid_shape_.size());
        for (int i = 0; i < grid_shape_.size(); ++i)
            feature_description_[i] = std::string(descriptor_names[i]);
    }

    double sim_time_out() const { return sim_time_out_; }
    void set_sim_time_out(double new_time_out) { sim_time_out_ = new_time_out; }

    std::string env() const;
    void add_waypoint(double x, double y, double z);
    const std::vector<std::vector<double>>& get_waypoints() const { return waypoints_; }
    void set_camera(double from_x, double from_y, double from_z,
                    double to_x, double to_y, double to_z);

    friend std::ostream& operator<< (std::ostream &out, const EvoGenTrainingConfigs& configs);

  private:
    // EvoParams
    int num_gen_ = 0;
    int init_pop_size_ = 0;
    int pop_size_ = 0;
    int num_user_inputs_ = 0;
    std::vector<int> grid_dim_;
    double sim_time_ = 0;
    std::string env_ = "";
    std::string output_dir_ = "";
    enum UserDesignSampling input_sampling_ = ALL;
    std::string evaluator_;;

    // Below are the newly added fields not yet in use
    bool enable_output_ = true;
    size_t rand_seed_ = 1;
    int init_size_ = 30;
    int progress_dump_period_ = 1;
    int output_write_period_ = 1;
    bool output_all_robots_ = false;
    double phen_data_min_ = 0.5; // gen data is always in [0, 1]
    double phen_data_max_ = 1.5;
    // TODO: figure out a proper arrangement for the grid shape configuration
    // The grid shape seems to be highly related to the source code, i.e. the
    // evaluation of different need to be encoded into the fitness evaluation,
    // which guarantees that the number of dimensions needed to be fixed at compilation
    // time. And the configuration of the container of the gridmap (boost::multi_array)
    // also needs to know the dimension at compilation time.
    // So what could be configured at run time is the number of bins of each dimension.
    // And if we pre-code the different possible gridshape dimensions into the code,
    // a run time selection maybe possible
    std::vector<int> grid_shape_ = {20, 20};
    std::vector<std::string> feature_description_;

    // SimParams
    double sim_time_out_ = 5;
    std::string env_name_ = "ground";
    std::string env_dir_ = ".";
    std::string parts_dir_ = ".";
    double env_dim_[3] = {5, 3, 0.01};
    double env_rot_[4] = {1, 0, 0, 0}; // w, x, y, z
    bool do_viz_ = false;
    bool do_realtime_ = false;
    double camera_pos_[6] = {0, -1, 1, 0, 0, 0}; // from (0, -1, 1) to (0, 0, 0)
    std::vector<std::vector<double>> waypoints_;
};

#endif /* end of include guard: EVOGEN_GENERATOR_INCLUDE_TRAININGCONFIGS_H_ */
