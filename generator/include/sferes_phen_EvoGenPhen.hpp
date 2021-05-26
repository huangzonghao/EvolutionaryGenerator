#ifndef SFERES_PHEN_EVOGENPHEN_HPP_OZY0FBGR
#define SFERES_PHEN_EVOGENPHEN_HPP_OZY0FBGR
#include <vector>
#include <iostream>
#include <boost/serialization/nvp.hpp>

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
    void mutate() { this->_gen.mutate(); }
    void random() { this->_gen.random(); }

    void cross(const std::shared_ptr<EvoGenPhen> i2,
               std::shared_ptr<EvoGenPhen>& o1,
               std::shared_ptr<EvoGenPhen>& o2) {
        if (!o1)
            o1 = std::make_shared<EvoGenPhen>(_max_p, _min_p);
        if (!o2)
            o2 = std::make_shared<EvoGenPhen>(_max_p, _min_p);
        _gen.cross(i2->gen(), o1->gen(), o2->gen());
    }

    // phen format: [body_x, body_y, body_z, num_legs, leg_1, leg_2, ...]
    //     for each leg: [leg_pos, num_links, link_1_id, link_1_scale]
    // Note: phen holds the design vector that should be directly send to robot
    // generator, and therefore would contain digits not included in gen to record
    // the assumptions
    // Here num_legs hold the number of legs on both sides, making it a double of
    // gen::num_legs
    // Leg order: FL FR ML MR BL BR
    void develop() {
        _phen_vec.clear();
        // body_x, body_y, body_z
        for (int i = 0; i < 3; ++i) {
                _phen_vec.push_back(_gen.data(i) * (_max_p - _min_p) + _min_p);
        }
        // legs
        double pos_tmp;
        int num_legs_gen = _gen.data(3);
        int gen_cursor = 4;
        _phen_vec.push_back(num_legs_gen * 2);
        for (int i = 0; i < num_legs_gen; ++i) {
            if (i == 1 && num_legs_gen == 2)
                pos_tmp = pos[2];
            else
                pos_tmp = pos[i];
            _phen_vec.push_back(pos_tmp);
            int num_links = _gen.data(gen_cursor);
            _phen_vec.push_back(num_links);
            for (int j = 0; j < num_links; ++j) {
                _phen_vec.push_back(_gen.data(gen_cursor+1+j*2)); // link id
                _phen_vec.push_back(_gen.data(gen_cursor+1+j*2+1) * (_max_p - _min_p) + _min_p); // link scale
            }

            // mirror the leg
            _phen_vec.push_back(1 - pos_tmp); // mirrored pos
            _phen_vec.push_back(num_links);
            for (int j = 0; j < num_links; ++j) {
                _phen_vec.push_back(_gen.data(gen_cursor+1+j*2)); // link id
                _phen_vec.push_back(_gen.data(gen_cursor+1+j*2+1) * (_max_p - _min_p) + _min_p); // link scale
            }

            gen_cursor += num_links * 2 + 1;
        }
    }

    double data(size_t i) const {
        assert(i < size());
        return _phen_vec[i];
    }
    size_t size() const { return _phen_vec.size(); }
    const std::vector<double>& data() const { return _phen_vec; }

    // squared Euclidean distance
    double dist(const EvoGenPhen& params) const {
        assert(params.size() == size());
        double d = 0.0f;
        for (size_t i = 0; i < _phen_vec.size(); ++i) {
            double x = _phen_vec[i] - params._phen_vec[i];
            d += x * x;
        }
        return d;
    }

    void show(std::ostream& os) const {
        for (auto p : _phen_vec)
            os << p << " " << std::endl;
    }

    void set_params(const EvoParams& evo_params) {
        _max_p = evo_params.phen_data_max();
        _min_p = evo_params.phen_data_min();
    }

    template<class Archive>
    void serialize(Archive & ar, const unsigned int version) {
        ar & BOOST_SERIALIZATION_NVP(_gen);
        ar & BOOST_SERIALIZATION_NVP(_fit);
    }

  protected:
    Gen _gen;
    Fit _fit;
    std::vector<double> _phen_vec;
    double _max_p;
    double _min_p;
    const double pos[3] = {0.01, 0.25, 0.49};
};

template<typename G, typename F>
std::ostream& operator<<(std::ostream& output, const EvoGenPhen<G, F>& e) {
    for (size_t i = 0; i < e.size(); ++i)
        output << " " << e.data(i) ;
    return output;
}

} // namespace phen
} // namespace sferes
#endif /* end of include guard: SFERES_PHEN_EVOGENPHEN_HPP_OZY0FBGR */
