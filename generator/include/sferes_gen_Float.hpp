#ifndef SFERES_GEN_FLOAT_HPP_S58RFK3M
#define SFERES_GEN_FLOAT_HPP_S58RFK3M

#include <vector>
#include <limits>
#include <boost/foreach.hpp>
#include <boost/serialization/vector.hpp>
#include <boost/serialization/nvp.hpp>
#include <sferes/stc.hpp>
#include <sferes/misc.hpp>
#include <sferes/dbg/dbg.hpp>
#include <iostream>
#include <cmath>

namespace sferes {
namespace gen {
// A basic class that represent an array of float, typically in range [0;1]
// it is used by CMAES and EvoFloat derives from this class
template<typename Exact = stc::Itself>
class Float : public stc::Any<Exact> {
  public:
    Float() : _data(16) {}
    // std::fill(_data.begin(), _data.end(), 0.5f);

    // should not be used (use evo_float)
    void mutate() { assert(0); }
    void cross(const Float& o, Float& c1, Float& c2) { assert(0); }
    void random() { assert(0); }

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
    std::vector<double> _data;
}; // class Float
} // namespace gen
} // namespace sferes

#endif /* end of include guard: SFERES_GEN_FLOAT_HPP_S58RFK3M */
