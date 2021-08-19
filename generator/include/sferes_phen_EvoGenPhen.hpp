#ifndef EVOGEN_GENERATOR_SFERES_PHEN_EVOGENPHEN_HPP_
#define EVOGEN_GENERATOR_SFERES_PHEN_EVOGENPHEN_HPP_

#include <vector>
#include <iostream>
#include <boost/serialization/nvp.hpp>

#include "RobotRepresentation.h"
#include "EvoParams.h"

namespace sferes {
namespace phen {

template <typename Gen, typename Fit>
class EvoGenPhen {
  public:
    typedef Fit fit_t;
    typedef Gen gen_t;

    template<typename G, typename F>
    friend std::ostream& operator<<(std::ostream& output, const EvoGenPhen<G, F>& e);

    EvoGenPhen() {}
    EvoGenPhen(double max_p, double min_p) : _max_p(max_p), _min_p(min_p) {}
    EvoGenPhen(const EvoParams& evo_params) { set_params(evo_params); }

    Fit& fit() { return _fit; }
    const Fit& fit() const { return _fit; }

    Gen& gen()  { return _gen; }
    const Gen& gen() const { return _gen; }
    void mutate() { _gen.mutate(); }
    void random() { _gen.random(); }

    void cross(const std::shared_ptr<EvoGenPhen> i2,
               std::shared_ptr<EvoGenPhen>& o1,
               std::shared_ptr<EvoGenPhen>& o2) {
        if (!o1)
            o1 = std::make_shared<EvoGenPhen>(_max_p, _min_p);
        if (!o2)
            o2 = std::make_shared<EvoGenPhen>(_max_p, _min_p);
        _gen.cross(i2->gen(), o1->gen(), o2->gen());
    }

    // Genome to Robot Conversion
    // gen format: [body_id, body_x, body_y, body_z, num_legs, leg_1, leg_2, ...]
    //     for each leg: [leg_pos, num_links, link_1_id, link_1_scale]
    // Leg order: FL FR ML MR BL BR
    void develop() {
        _robot.decode_design_vector(_gen.data());
    }

    double data(size_t i) const {
        assert(i < size());
        return _gen.data(i);
    }
    size_t size() const { return _gen.size(); }
    const std::vector<double>& data() const { return _gen.data(); }

    // squared Euclidean distance
    double dist(const EvoGenPhen& params) const {
        assert(params.size() == size());
        double d = 0.0f;
        for (size_t i = 0; i < _gen.size(); ++i) {
            double x = this->data(i) - params.data(i);
            d += x * x;
        }
        return d;
    }

    void show(std::ostream& os) const {
        for (auto p : _gen.data())
            os << p << " " << std::endl;
    }

    void set_params(const EvoParams& evo_params) {
        _max_p = evo_params.phen_data_max();
        _min_p = evo_params.phen_data_min();
    }

    const RobotRepresentation& get_robot() { return _robot; }

    template<class Archive>
    void serialize(Archive & ar, const unsigned int version) {
        ar & BOOST_SERIALIZATION_NVP(_gen);
        ar & BOOST_SERIALIZATION_NVP(_fit);
    }

  protected:
    Gen _gen;
    Fit _fit;
    double _max_p;
    double _min_p;
    const double pos[3] = {0.01, 0.25, 0.49};
    RobotRepresentation _robot;
};

template<typename G, typename F>
std::ostream& operator<<(std::ostream& output, const EvoGenPhen<G, F>& e) {
    output << _robot;
    return output;
}

} // namespace phen
} // namespace sferes

#endif /* end of include guard: EVOGEN_GENERATOR_SFERES_PHEN_EVOGENPHEN_HPP_ */
