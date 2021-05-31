#ifndef SFERES_GEN_EVOGENFLOAT_HPP_TDPDVGME
#define SFERES_GEN_EVOGENFLOAT_HPP_TDPDVGME

#include <cmath>
#include <vector>
#include <limits>
#include <iostream>
#include <algorithm>
#include <boost/serialization/vector.hpp>
#include <boost/serialization/nvp.hpp>
#include "rand.hpp"

namespace sferes {
namespace gen {

static const double gen_mutation_rate = 0.1f;
static const double gen_eta_m = 10.0f;
static const double gen_cross_rate = 0.75f;
static const double gen_eta_c = 10.0f;
static const double gen_yl = 0.0;
static const double gen_yu = 1.0;
static const int max_num_legs = 3;
static const int min_num_legs = 2;
static const int max_num_links = 3;
static const int min_num_links = 1;

namespace evo_float {

// polynomial mutation. Cf Deb 2001, p 124 ; param: gen_eta_m
// perturbation of the order O(1/eta_m)
template<typename Ev>
struct Mutation_f {
    double operator()(double raw) {
        assert(gen_eta_m != -1.0f);
        double ri = misc::rand<double>();
        double delta_i = ri < 0.5 ?
                         pow(2.0 * ri, 1.0 / (gen_eta_m + 1.0)) - 1.0 :
                         1 - pow(2.0 * (1.0 - ri), 1.0 / (gen_eta_m + 1.0));
        assert(!std::isnan(delta_i));
        assert(!std::isinf(delta_i));
        return std::clamp(raw + delta_i, 0.0, 1.0);
    }
    int operator()(int raw) {
        if (misc::flip_coin())
            raw += 1;
        else
            raw -= 1;
        return raw;
    }
};

// SBX (cf Deb 2001, p 113) Simulated Binary Crossover
// suggested eta : 15
/// WARNING : this code is from deb's code (different from the
// article ...)
// A large value ef eta gives a higher probablitity for
// creating a `near-parent' solutions and a small value allows
// distant solutions to be selected as offspring.
template<typename Ev>
struct CrossOver_f {
    void operator()(const Ev& f1, const Ev& f2, Ev &child1, Ev &child2) {
        assert(gen_eta_c != -1);
        for (unsigned int i = 0; i < f1.size(); i++) {
            double y1 = std::min(f1.data(i), f2.data(i));
            double y2 = std::max(f1.data(i), f2.data(i));
            if (fabs(y1 - y2) > std::numeric_limits<double>::epsilon()) {
                double rand = misc::rand<double>();
                double beta = 1.0 + (2.0 * (y1 - gen_yl) / (y2 - y1));
                double alpha = 2.0 - pow(beta, -(gen_eta_c + 1.0));
                double betaq = 0;
                if (rand <= (1.0 / alpha))
                    betaq = pow((rand * alpha), (1.0 / (gen_eta_c + 1.0)));
                else
                    betaq = pow ((1.0 / (2.0 - rand * alpha)) , (1.0 / (gen_eta_c + 1.0)));
                double c1 = 0.5 * ((y1 + y2) - betaq * (y2 - y1));
                beta = 1.0 + (2.0 * (gen_yu - y2) / (y2 - y1));
                alpha = 2.0 - pow(beta, -(gen_eta_c + 1.0));
                if (rand <= (1.0 / alpha))
                    betaq = pow ((rand * alpha), (1.0 / (gen_eta_c + 1.0)));
                else
                    betaq = pow ((1.0/(2.0 - rand * alpha)), (1.0 / (gen_eta_c + 1.0)));
                double c2 = 0.5 * ((y1 + y2) + betaq * (y2 - y1));

                c1 = std::clamp(c1, gen_yl, gen_yu);
                c2 = std::clamp(c2, gen_yl, gen_yu);

                assert(!std::isnan(c1));
                assert(!std::isnan(c2));

                if (misc::flip_coin()) {
                    child1.data(i, c1);
                    child2.data(i, c2);
                } else {
                    child1.data(i, c2);
                    child2.data(i, c1);
                }
            }
            else{
                // case where y1 == y2
                // the two genes are the same (which may come for example,
                // when the two parents are the same individual)
                child1.data(i, y1);
                child2.data(i, y2);
            }
        }
    }
};
} // namespace evo_float

/// in range [0;1]
class EvoGenFloat {
  public:
    EvoGenFloat() {}

    void mutate() {
        std::vector<double> tmp_data;
        // TODO: how to improve memory management?
        tmp_data.reserve(_data.size());
        // body_x, body_y, body_z
        for (int i = 0; i < 3; ++i) {
            if (misc::rand<double>() < gen_mutation_rate)
                tmp_data.push_back(_mutation_op(_data[i]));
            else
                tmp_data.push_back(_data[i]);
        }
        // TODO: mutate num_links
        int num_legs = _data[3];
        int tmp_num_legs = num_legs;
        int num_links = 0;
        int tmp_num_links = 0;
        // first mutate num_legs
        if (misc::rand<double>() < gen_mutation_rate)
            tmp_num_legs = std::clamp(_mutation_op(tmp_num_legs), min_num_legs, max_num_legs);
        tmp_data.push_back(tmp_num_legs);
        int cursor = 4;
        if (num_legs >= tmp_num_legs) {
            for (int i = 0; i < tmp_num_legs; ++i) {
                num_links = _data[cursor];
                tmp_data.push_back(num_links);
                for (int j = 0; j < num_links * 2; ++j) {
                    if (misc::rand<double>() < gen_mutation_rate)
                        tmp_data.push_back(_mutation_op(_data[cursor + j + 1]));
                    else
                        tmp_data.push_back(_data[cursor + j + 1]);
                }
                cursor += num_links * 2 + 1;
            }
        } else {
            for (int i = 0; i < num_legs; ++i) {
                num_links = _data[cursor];
                tmp_data.push_back(num_links);
                for (int j = 0; j < num_links * 2; ++j) {
                    if (misc::rand<double>() < gen_mutation_rate)
                        tmp_data.push_back(_mutation_op(_data[cursor + j + 1]));
                    else
                        tmp_data.push_back(_data[cursor + j + 1]);
                }
                cursor += num_links * 2 + 1;
            }
            std::vector<double> tmp_leg;
            tmp_leg.reserve(30); // a randomly selected large number
            for (int i = 0; i < tmp_num_legs - num_legs; ++i) {
                generate_random_leg(tmp_leg);
                tmp_data.insert(tmp_data.end(), tmp_leg.begin(), tmp_leg.end());
            }
        }
        _data = tmp_data;
        _check_validity();
    }

    void generate_random_leg(std::vector<double>& leg_container) {
        leg_container.clear();
        int num_links = misc::rand<int>(min_num_links, max_num_links + 1);
        leg_container.push_back(num_links);
        for (int j = 0; j < num_links; ++j) {
            // id and scale are up to phen to interpret or pass on to generator
            leg_container.push_back(misc::rand<double>()); // link id
            leg_container.push_back(misc::rand<double>()); // link scale
        }
    }

    void cross(const EvoGenFloat& o, EvoGenFloat& c1, EvoGenFloat& c2) {
        if ( misc::rand<double>() < gen_cross_rate) {
            // TODO: define meaningful crossover operator
            // _cross_over_op(*this, o, c1, c2);
            c1 = *this;
            c2 = o;
        } else if (misc::flip_coin()) {
            c1 = *this;
            c2 = o;
        } else {
            c1 = o;
            c2 = *this;
        }
        _check_validity();
    }

    // gen format: [body_x, body_y, body_z, num_legs, leg_1, leg_2, ...]
    //     for each leg: [num_links, link_1_id, link_1_scale, ...]
    // Note: num_legs here corresponds to one side only
    void random() {
        _data.clear();
        _data.push_back(misc::rand<double>()); // body_x
        _data.push_back(misc::rand<double>()); // body_y
        _data.push_back(misc::rand<double>()); // body_z
        int num_legs = misc::rand<int>(min_num_legs, max_num_legs + 1);
        _data.push_back(num_legs);
        std::vector<double> tmp_leg;
        tmp_leg.reserve(30); // a randomly selected large number
        for (int i = 0; i < num_legs; ++i) {
            generate_random_leg(tmp_leg);
            _data.insert(_data.end(), tmp_leg.begin(), tmp_leg.end());
        }
        _check_validity();
    }

    const std::vector<double>& data() const { return _data; }
    double data(size_t i) const {
        assert(_data.size());
        assert(i < _data.size());
        return _data[i];
    }
    void data(size_t i, double v) {
        assert(_data.size());
        assert(i < _data.size());
        _data[i] = v;
    }

    size_t size() const { return _data.size(); }

    template<class Archive>
        void serialize(Archive & ar, const unsigned int version) {
        ar & BOOST_SERIALIZATION_NVP(_data);
    }

  protected:
    evo_float::Mutation_f<EvoGenFloat> _mutation_op;
    evo_float::CrossOver_f<EvoGenFloat> _cross_over_op;
    std::vector<double> _data;

    void _check_validity() const {
#ifndef NDEBUG
    for (auto p : _data) {
        assert(!std::isnan(p));
        assert(!std::isinf(p));
        assert(p >= 0 && p <= 1);
    }
#endif
    }
};
} // namespace gen
} // namespace sferes
#endif /* end of include guard: SFERES_GEN_EVOGENFLOAT_HPP_TDPDVGME */
