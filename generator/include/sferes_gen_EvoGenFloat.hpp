#ifndef SFERES_GEN_EVOGENFLOAT_HPP_TDPDVGME
#define SFERES_GEN_EVOGENFLOAT_HPP_TDPDVGME

#include <vector>
#include <limits>
#include <boost/foreach.hpp>
#include <boost/serialization/vector.hpp>
#include <boost/serialization/nvp.hpp>
#include <sferes/stc.hpp>
#include <sferes/misc.hpp>
#include <iostream>
#include <cmath>

SFERES_CONST double mutation_rate = 0.1f;
SFERES_CONST double eta_m = 10.0f;
SFERES_CONST double cross_rate = 0.75f;
SFERES_CONST double eta_c = 10.0f;

namespace sferes {
namespace gen {
namespace evo_float {

// polynomial mutation. Cf Deb 2001, p 124 ; param: eta_m
// perturbation of the order O(1/eta_m)
template<typename Ev>
struct Mutation_f {
    void operator()(Ev& ev, size_t i) {
        assert(eta_m != -1.0f);
        double ri = misc::rand<double>();
        double delta_i = ri < 0.5 ?
                         pow(2.0 * ri, 1.0 / (eta_m + 1.0)) - 1.0 :
                         1 - pow(2.0 * (1.0 - ri), 1.0 / (eta_m + 1.0));
        assert(!std::isnan(delta_i));
        assert(!std::isinf(delta_i));
        double f = ev.data(i) + delta_i;
        ev.data(i, misc::put_in_range(f, 0.0f, 1.0f));
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
        assert(eta_c != -1);
        for (unsigned int i = 0; i < f1.size(); i++) {
            double y1 = std::min(f1.data(i), f2.data(i));
            double y2 = std::max(f1.data(i), f2.data(i));
            SFERES_CONST double yl = 0.0;
            SFERES_CONST double yu = 1.0;
            if (fabs(y1 - y2) > std::numeric_limits<double>::epsilon()) {
                double rand = misc::rand<double>();
                double beta = 1.0 + (2.0 * (y1 - yl) / (y2 - y1));
                double alpha = 2.0 - pow(beta, -(eta_c + 1.0));
                double betaq = 0;
                if (rand <= (1.0 / alpha))
                    betaq = pow((rand * alpha), (1.0 / (eta_c + 1.0)));
                else
                    betaq = pow ((1.0 / (2.0 - rand * alpha)) , (1.0 / (eta_c + 1.0)));
                double c1 = 0.5 * ((y1 + y2) - betaq * (y2 - y1));
                beta = 1.0 + (2.0 * (yu - y2) / (y2 - y1));
                alpha = 2.0 - pow(beta, -(eta_c + 1.0));
                if (rand <= (1.0 / alpha))
                    betaq = pow ((rand * alpha), (1.0 / (eta_c + 1.0)));
                else
                    betaq = pow ((1.0/(2.0 - rand * alpha)), (1.0 / (eta_c + 1.0)));
                double c2 = 0.5 * ((y1 + y2) + betaq * (y2 - y1));

                c1 = misc::put_in_range(c1, yl, yu);
                c2 = misc::put_in_range(c2, yl, yu);

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
    EvoGenFloat() : _data(16) {}

    void mutate() {
        for (size_t i = 0; i < _data.size(); i++)
            if (misc::rand<double>() < mutation_rate)
            _mutation_op(*this, i);
        _check_invariant();
    }
    void cross(const EvoGenFloat& o, EvoGenFloat& c1, EvoGenFloat& c2) {
        if ( misc::rand<double>() < cross_rate)
            _cross_over_op(*this, o, c1, c2);
        else if (misc::flip_coin()) {
            c1 = *this;
            c2 = o;
        } else {
            c1 = o;
            c2 = *this;
        }
        _check_invariant();
    }
    void random() {
        BOOST_FOREACH(double &v, this->_data) v = misc::rand<double>();
        _check_invariant();
    }
    const std::vector<double>& data() const { return this->_data; }
    double data(size_t i) const {
        assert(this->_data.size());
        assert(i < this->_data.size());
        assert(!std::isinf(this->_data[i]));
        assert(!std::isnan(this->_data[i]));
        return this->_data[i];
    }
    void data(size_t i, double v) {
        assert(this->_data.size());
        assert(i < this->_data.size());
        assert(!std::isinf(v));
        assert(!std::isnan(v));
        this->_data[i] = v;
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

    void _check_invariant() const {
#ifndef NDEBUG
    BOOST_FOREACH(double p, this->_data) {
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
