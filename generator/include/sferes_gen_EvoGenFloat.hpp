#ifndef EVOGEN_GENERATOR_SFERES_GEN_EVOGENFLOAT_HPP_
#define EVOGEN_GENERATOR_SFERES_GEN_EVOGENFLOAT_HPP_

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
static const int max_num_legs_oneside = 3;
static const int min_num_legs_oneside = 1;
static const int max_num_links = 3;
static const int min_num_links = 2;

namespace evo_float {

// polynomial mutation. Cf Deb 2001, p 124 ; param: gen_eta_m
// perturbation of the order O(1/eta_m)
template<typename Ev>
struct Mutation_f {
    double operator()(double raw, double min = 0.0, double max = 1.0) {
        assert(gen_eta_m != -1.0f);
        double ri = misc::rand<double>();
        double delta_i = ri < 0.5 ?
                         pow(2.0 * ri, 1.0 / (gen_eta_m + 1.0)) - 1.0 :
                         1 - pow(2.0 * (1.0 - ri), 1.0 / (gen_eta_m + 1.0));
        assert(!std::isnan(delta_i));
        assert(!std::isinf(delta_i));
        return std::clamp(raw + delta_i, min, max);
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

/// in range [0, 1]
class EvoGenFloat {
  public:
    EvoGenFloat() {}

    // TODO: the mutation code could look much cleaner if all genomes have containers
    // with same size regardless of genome's actual length
    void mutate() {
        std::vector<double> tmp_data;
        // TODO: how to improve memory management?
        tmp_data.reserve(_data.size());
        int cursor = 0;
        // body_id
        if (misc::rand<double>() < gen_mutation_rate)
            tmp_data.push_back(_mutation_op(_data[cursor++]));
        else
            tmp_data.push_back(_data[cursor++]);

        // body_x, body_y, body_z
        for (int i = 0; i < 3; ++i) {
            if (misc::rand<double>() < gen_mutation_rate)
                tmp_data.push_back(_mutation_op(_data[cursor++]));
            else
                tmp_data.push_back(_data[cursor++]);
        }

        // Mutate num_legs
        int current_num_legs = _data[cursor++];
        int new_num_legs = current_num_legs;
        int current_num_links = 0;
        std::vector<double> tmp_leg;
        tmp_leg.reserve(30); // a randomly selected large number
        if (misc::rand<double>() < gen_mutation_rate)
            new_num_legs = std::clamp(_mutation_op(new_num_legs), min_num_legs_oneside, max_num_legs_oneside);
        // TODO: Need to think about the num_leg mutation again
        new_num_legs = current_num_legs; // disable num_leg mutation
        tmp_data.push_back(new_num_legs);
        int leg_cursor_left;

        // Mutate legs
        for (int i = 0; i < std::min(current_num_legs, new_num_legs); ++i) {
            // Mutate leg_pos
            double leg_pos = _data[cursor++];
            if (misc::rand<double>() < gen_mutation_rate) {
                if (leg_pos < 0.5)
                    tmp_data.push_back(_mutation_op(leg_pos, 0.01, 0.49));
                else
                    tmp_data.push_back(_mutation_op(leg_pos, 0.51, 0.99));
            } else {
                tmp_data.push_back(leg_pos);
            }

            // Mutate num_links
            int current_num_links = _data[cursor++];
            int new_num_links = current_num_links;
            if (misc::rand<double>() < gen_mutation_rate)
                new_num_links = std::clamp(_mutation_op(new_num_links), min_num_links, max_num_links);
            tmp_data.push_back(new_num_links);

            // Mutate links
            for (int i = 0; i < std::min(current_num_links, new_num_links) * 2; ++i) {
                if (misc::rand<double>() < gen_mutation_rate)
                    tmp_data.push_back(_mutation_op(_data[cursor++]));
                else
                    tmp_data.push_back(_data[cursor++]);
            }

            for (int i = 0; i < (new_num_links - current_num_links) * 2; ++i) {
                tmp_data.push_back(misc::rand<double>()); // link id
                tmp_data.push_back(misc::rand<double>()); // link scale
            }
        }

        for (int i = 0; i < new_num_legs - current_num_legs; ++i) {
            generate_random_leg(tmp_leg, 0); // TODO: need to think about which side to add
            tmp_data.insert(tmp_data.end(), tmp_leg.begin(), tmp_leg.end());
        }

        _data = tmp_data;
        _check_validity();
    }

    // leg_side: 0 - left, 1 - right
    void generate_random_leg(std::vector<double>& leg_container, int leg_side) {
        leg_container.clear();
        if (leg_side == 0) { // left leg
            leg_container.push_back(misc::rand<double>(0.01, 0.49)); // leg pos
        } else { // right leg
            leg_container.push_back(misc::rand<double>(0.51, 0.99)); // leg pos
        }
        int num_links = misc::rand<int>(min_num_links, max_num_links + 1);
        leg_container.push_back(num_links);
        for (int j = 0; j < num_links; ++j) {
            // id and scale are up to phen to interpret or pass on to generator
            leg_container.push_back(misc::rand<double>()); // link id
            leg_container.push_back(misc::rand<double>()); // link scale
        }
    }

    void cross(const EvoGenFloat& o, EvoGenFloat& c1, EvoGenFloat& c2) {
        if (misc::rand<double>() < gen_cross_rate) {
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

    // gen format: [body_id, body_x, body_y, body_z, num_legs, leg_1, leg_2, ...]
    //     for each leg: [leg_pos, num_links, link_1_id, link_1_scale, ...]
    // Note: num_legs here corresponds to one side only
    // Leg order: L R (the internal order within each side is not guaranteed here)
    void random() {
        _data.clear();
        _data.push_back(misc::rand<double>()); // body_id
        _data.push_back(misc::rand<double>()); // body_x
        _data.push_back(misc::rand<double>()); // body_y
        _data.push_back(misc::rand<double>()); // body_z
        int num_legs_left = misc::rand<int>(min_num_legs_oneside, max_num_legs_oneside + 1);
        int num_legs_right = misc::rand<int>(min_num_legs_oneside, max_num_legs_oneside + 1);

        // TODO: force two sides to have the same number of legs for now
        num_legs_right = num_legs_left;

        _data.push_back(num_legs_left + num_legs_right);
        std::vector<double> tmp_leg;
        tmp_leg.reserve(30); // a randomly selected large number
        for (int i = 0; i < num_legs_left; ++i) {
            generate_random_leg(tmp_leg, 0);
            _data.insert(_data.end(), tmp_leg.begin(), tmp_leg.end());
        }
        for (int i = 0; i < num_legs_right; ++i) {
            generate_random_leg(tmp_leg, 1);
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

#endif /* end of include guard: EVOGEN_GENERATOR_SFERES_GEN_EVOGENFLOAT_HPP_ */
