#ifndef SFERES_PHEN_EVOGENPHEN_HPP_OZY0FBGR
#define SFERES_PHEN_EVOGENPHEN_HPP_OZY0FBGR
#include <vector>
#include <sferes/phen/indiv.hpp>
#include <boost/foreach.hpp>

#include "EvoParams.h"

namespace sferes {
namespace phen {

SFERES_INDIV(EvoGenPhen, Indiv) {
    template<typename G, typename F, typename P, typename E>
    friend std::ostream& operator<<(std::ostream& output, const EvoGenPhen< G, F, P, E >& e);
  public:
#ifdef EIGEN_CORE_H
    EIGEN_MAKE_ALIGNED_OPERATOR_NEW
#endif
    EvoGenPhen() {}
    EvoGenPhen(double max_p, double min_p) : _max_p(max_p), _min_p(min_p), _params((*this)._gen.size()) {}
    EvoGenPhen(const EvoParams& evo_params) : _params((*this)._gen.size()) { set_params(evo_params); }

    void cross(const boost::shared_ptr<EvoGenPhen> i2,
               boost::shared_ptr<EvoGenPhen>& o1,
               boost::shared_ptr<EvoGenPhen>& o2) {
        dbg::trace trace("phen", DBG_HERE);
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

    float data(size_t i) const {
        assert(i < size());
        return _params[i];
    }
    size_t size() const { return _params.size(); }
    const std::vector<float>& data() const { return _params; }

    // squared Euclidean distance
    float dist(const EvoGenPhen& params) const {
        assert(params.size() == size());
        float d = 0.0f;
        for (size_t i = 0; i < _params.size(); ++i) {
            float x = _params[i] - params._params[i];
            d += x * x;
        }
        return d;
    }

    void show(std::ostream& os) const {
        BOOST_FOREACH(float p, _params)
        os << p << " " << std::endl;
    }

    void set_params(const EvoParams& evo_params) {
        _max_p = evo_params.phen_data_max();
        _min_p = evo_params.phen_data_min();
    }
  protected:
    std::vector<float> _params;
    double _max_p;
    double _min_p;
};

template<typename G, typename F, typename P, typename E>
std::ostream& operator<<(std::ostream& output, const EvoGenPhen< G, F, P, E >& e) {
    for (size_t i = 0; i < e.size(); ++i)
    output << " " << e.data(i) ;
    return output;
}

} // namespace phen
} // namespace sferes
#endif /* end of include guard: SFERES_PHEN_EVOGENPHEN_HPP_OZY0FBGR */
