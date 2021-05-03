#ifndef EVOPARAMS_H_XHAR4NLN
#define EVOPARAMS_H_XHAR4NLN

#include <vector>
#include <boost/serialization/nvp.hpp>

class EvoParams {
  public:
    const size_t nb_gen() const { return nb_gen_; }
    const size_t init_size() const { return init_size_; }
    const size_t pop_size() const { return pop_size_; }
    const size_t progress_dump_period() const { return progress_dump_period_; }
    const size_t output_write_period() const { return output_write_period_; }
    const bool output_all_robots() const { return output_all_robots_; }
    const double phen_data_min() const { return phen_data_min_; }
    const double phen_data_max() const { return phen_data_max_; }
    const std::vector<size_t>& grid_shape() const { return grid_shape_; }

    void set_nb_gen(size_t nb_gen) { nb_gen_ = nb_gen; }

    template<class Archive>
    void serialize(Archive & ar, const unsigned int version) {
        ar & BOOST_SERIALIZATION_NVP(nb_gen_);
        ar & BOOST_SERIALIZATION_NVP(init_size_);
        ar & BOOST_SERIALIZATION_NVP(pop_size_);
        ar & BOOST_SERIALIZATION_NVP(progress_dump_period_);
        ar & BOOST_SERIALIZATION_NVP(output_write_period_);
        ar & BOOST_SERIALIZATION_NVP(output_all_robots_);
        ar & BOOST_SERIALIZATION_NVP(phen_data_min_);
        ar & BOOST_SERIALIZATION_NVP(phen_data_max_);
        ar & BOOST_SERIALIZATION_NVP(grid_shape_);
    }
  private:
    size_t nb_gen_ = 30;
    size_t init_size_ = 30;
    size_t pop_size_ = 30;
    size_t progress_dump_period_ = 1;
    size_t output_write_period_ = 1;
    bool output_all_robots_ = false;
    double phen_data_min_ = 0.5; // gen data is always in [0, 1]
    double phen_data_max_ = 1.5;
    std::vector<size_t> grid_shape_ = {20, 20};
};

#endif /* end of include guard: EVOPARAMS_H_XHAR4NLN */