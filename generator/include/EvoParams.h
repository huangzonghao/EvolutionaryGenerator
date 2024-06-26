#ifndef EVOGEN_GENERATOR_EVOPARAMS_H_
#define EVOGEN_GENERATOR_EVOPARAMS_H_

#include <string>
#include <vector>
#include <boost/serialization/string.hpp>
#include <boost/serialization/nvp.hpp>
#include <boost/serialization/version.hpp>

class EvoParams {
  public:
    // TODO: merge the public defination here with the one in training_configs,
    // right now they are not stored in the serialized file
    enum UserDesignSampling { ALL = 0, RANDOM };
    enum UserDesignSampling input_sampling = ALL;
    int num_user_inputs = 0;

    size_t& rand_seed() { return rand_seed_; }
    const size_t rand_seed() const { return rand_seed_; }
    const size_t nb_gen() const { return nb_gen_; }
    const size_t init_size() const { return init_size_; }
    const size_t pop_size() const { return pop_size_; }
    const size_t progress_dump_period() const { return progress_dump_period_; }
    const size_t output_write_period() const { return output_write_period_; }
    const bool output_all_robots() const { return output_all_robots_; }
    const double phen_data_min() const { return phen_data_min_; }
    const double phen_data_max() const { return phen_data_max_; }
    const std::vector<int>& grid_shape() const { return grid_shape_; }
    bool output_enabled() const { return enable_output_; }
    std::vector<std::string>& feature_description() { return feature_description_; }
    const std::string& evaluator() { return evaluator_; }

    void set_grid_shape(const std::vector<int>& grid_shape) { grid_shape_ = grid_shape; }
    void set_nb_gen(size_t nb_gen) { nb_gen_ = nb_gen; }
    void set_init_size(size_t init_size) { init_size_ = init_size; }
    void set_pop_size(size_t pop_size) { pop_size_ = pop_size; }
    bool set_feature_description(const char* const* descriptor_names) {
        feature_description_.clear();
        feature_description_.resize(grid_shape_.size());
        for (int i = 0; i < grid_shape_.size(); ++i)
            feature_description_[i] = std::string(descriptor_names[i]);
    }
    void set_evaluator(const std::string& evaluator) { evaluator_ = evaluator; }

    bool Save(const std::string& filename) const;
    bool Load(const std::string& filename);

    template<class Archive>
    void serialize(Archive & ar, const unsigned int version) {
        ar & BOOST_SERIALIZATION_NVP(enable_output_);
        ar & BOOST_SERIALIZATION_NVP(rand_seed_);
        ar & BOOST_SERIALIZATION_NVP(nb_gen_);
        ar & BOOST_SERIALIZATION_NVP(init_size_);
        ar & BOOST_SERIALIZATION_NVP(pop_size_);
        ar & BOOST_SERIALIZATION_NVP(progress_dump_period_);
        ar & BOOST_SERIALIZATION_NVP(output_write_period_);
        ar & BOOST_SERIALIZATION_NVP(output_all_robots_);
        ar & BOOST_SERIALIZATION_NVP(phen_data_min_);
        ar & BOOST_SERIALIZATION_NVP(phen_data_max_);
        ar & BOOST_SERIALIZATION_NVP(grid_shape_);
        ar & BOOST_SERIALIZATION_NVP(feature_description_);
        if (version >= 1) {
            ar & BOOST_SERIALIZATION_NVP(evaluator_);
        }
    }
  private:
    bool enable_output_ = true;
    size_t rand_seed_ = 1;
    size_t nb_gen_ = 30;
    size_t init_size_ = 30;
    size_t pop_size_ = 30;
    size_t progress_dump_period_ = 1;
    size_t output_write_period_ = 1;
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
    std::string evaluator_;

};

BOOST_CLASS_VERSION(EvoParams, 1)

#endif /* end of include guard: EVOGEN_GENERATOR_EVOPARAMS_H_ */
