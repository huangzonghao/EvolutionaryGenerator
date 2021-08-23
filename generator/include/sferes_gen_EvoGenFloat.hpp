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
static const int evogen_gene_max_size = 53;

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
    // TODO: how to pass in this data appropriately.

    EvoGenFloat() : _max_size(evogen_gene_max_size) { _data.resize(_max_size); }
    EvoGenFloat(int max_size) : _max_size(max_size) { _data.resize(_max_size); }
    EvoGenFloat(const std::vector<double>& data) : _data(data) {}

    void mutate() {
        for (auto& element : _data) {
            if (misc::rand<double>() < gen_mutation_rate)
                element = _mutation_op(element);
        }
    }

    void cross(const EvoGenFloat& other, EvoGenFloat& c1, EvoGenFloat& c2) {
        if (misc::rand<double>() < gen_cross_rate) {
            _cross_over_op(*this, other, c1, c2);
        } else if (misc::flip_coin()) {
            c1 = *this;
            c2 = other;
        } else {
            c1 = other;
            c2 = *this;
        }
    }

    void random() {
        _data.resize(_max_size);
        for (auto& element : _data)
            element = misc::rand<double>();
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
    void resize(int new_size) { _data.resize(new_size); }

    template<class Archive>
        void serialize(Archive & ar, const unsigned int version) {
        ar & BOOST_SERIALIZATION_NVP(_max_size);
        ar & BOOST_SERIALIZATION_NVP(_data);
    }

  protected:
    evo_float::Mutation_f<EvoGenFloat> _mutation_op;
    evo_float::CrossOver_f<EvoGenFloat> _cross_over_op;
    std::vector<double> _data;
    int _max_size = 0;

};

} // namespace gen
} // namespace sferes

#endif /* end of include guard: EVOGEN_GENERATOR_SFERES_GEN_EVOGENFLOAT_HPP_ */
