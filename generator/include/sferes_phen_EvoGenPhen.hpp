#ifndef SFERES_PHEN_EVOGENPHEN_HPP_OZY0FBGR
#define SFERES_PHEN_EVOGENPHEN_HPP_OZY0FBGR
#include <vector>
#include <iostream>
#include <boost/shared_ptr.hpp>
#include <boost/foreach.hpp>
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

    EvoGenPhen() : _params((*this)._gen.size()) {}
    EvoGenPhen(double max_p, double min_p) : _max_p(max_p), _min_p(min_p), _params((*this)._gen.size()) {}
    EvoGenPhen(const EvoParams& evo_params) : _params((*this)._gen.size()) { set_params(evo_params); }

    Fit& fit() { return _fit; }
    const Fit& fit() const { return _fit; }

    Gen& gen()  { return _gen; }
    const Gen& gen() const { return _gen; }
    void mutate() { this->_gen.mutate(); }
    void random() { this->_gen.random(); }

    void cross(const boost::shared_ptr<EvoGenPhen> i2,
               boost::shared_ptr<EvoGenPhen>& o1,
               boost::shared_ptr<EvoGenPhen>& o2) {
        if (!o1)
            o1 = boost::shared_ptr<EvoGenPhen>(new EvoGenPhen(_max_p, _min_p));
        if (!o2)
            o2 = boost::shared_ptr<EvoGenPhen>(new EvoGenPhen(_max_p, _min_p));
        _gen.cross(i2->gen(), o1->gen(), o2->gen());
    }

    void develop() {
        for (unsigned i = 0; i < _params.size(); ++i)
            _params[i] = this->_gen.data(i) * (_max_p - _min_p) + _min_p;
    }

    double data(size_t i) const {
        assert(i < size());
        return _params[i];
    }
    size_t size() const { return _params.size(); }
    const std::vector<double>& data() const { return _params; }

    // squared Euclidean distance
    double dist(const EvoGenPhen& params) const {
        assert(params.size() == size());
        double d = 0.0f;
        for (size_t i = 0; i < _params.size(); ++i) {
            double x = _params[i] - params._params[i];
            d += x * x;
        }
        return d;
    }

    void show(std::ostream& os) const {
        BOOST_FOREACH(double p, _params)
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
    std::vector<double> _params;
    double _max_p;
    double _min_p;
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
