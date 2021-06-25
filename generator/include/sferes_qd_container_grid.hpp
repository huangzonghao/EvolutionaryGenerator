#ifndef SFERES_QD_CONTAINER_GRID_HPP_UNXK1HEF
#define SFERES_QD_CONTAINER_GRID_HPP_UNXK1HEF
// #include <tbb/parallel_for_each.h>
#include <cmath>
#include <boost/multi_array.hpp>
#include <boost/archive/binary_oarchive.hpp>
#include <boost/archive/binary_iarchive.hpp>

#include "EvoParams.h"

namespace sferes {
namespace qd {
namespace container {

namespace nov {
    static const size_t deep = 2;
    static const double l = 1;
    static const double k = 8;
    static const double eps = 0.01;
}

template <typename Phen>
class Grid {
  public:

    static const size_t dim = 2;

    typedef std::shared_ptr<Phen> indiv_t;
    typedef typename std::vector<indiv_t> pop_t;
    typedef typename pop_t::iterator it_t;
    typedef typename std::vector<std::vector<indiv_t>> front_t;

    typedef boost::multi_array<indiv_t, dim> array_t;
    typedef typename array_t::multi_array_base::index_range index_range_t;
    typedef boost::detail::multi_array::index_gen<dim, dim> index_gen_t;
    typedef typename array_t::template const_array_view<dim>::type view_t;
    typedef boost::array<typename array_t::index, dim> behav_index_t;
    typedef boost::array<double, dim> point_t;

    behav_index_t grid_shape = {20, 20};

    Grid()
    {
        // allocate space for _array and _array_parents
        _array.resize(grid_shape);
    }

    void set_params(const EvoParams& evo_params) {
        for (int i = 0; i < evo_params.grid_shape().size(); ++i)
            grid_shape[i] = evo_params.grid_shape()[i];
        _array.resize(grid_shape);
    }

    template <typename I> behav_index_t get_index(const I& indiv) const
    {
        point_t p = get_point(indiv);
        behav_index_t behav_pos;
        for (size_t i = 0; i < grid_shape.size(); ++i) {
            behav_pos[i] = round(p[i] * (grid_shape[i] - 1));
            assert(behav_pos[i] < grid_shape[i]);
        }
        return behav_pos;
    }

    void get_full_content(std::vector<indiv_t>& container) const
    {
        container.resize(_num_filled);
        int counter = 0;
        for (const indiv_t* ind = _array.data(); ind < (_array.data() + _array.num_elements()); ++ind)
            if (*ind) container[counter++] = *ind;

        assert(counter + 1 == _num_filled);
    }

    bool add(indiv_t i1)
    {
        if (i1->fit().dead())
            return false;

        behav_index_t behav_pos = get_index(i1);

        const double epsilon = 0.00;
        if (!_array(behav_pos)) {
            _num_filled++;
            goto add_to_container;
        }
        if (i1->fit().value() - _array(behav_pos)->fit().value() > epsilon)
            goto add_to_container;
        // TODO: why?
        // same fitness but the features are closer to the center of map
        if (std::abs(i1->fit().value() - _array(behav_pos)->fit().value()) <= epsilon &&
            _dist_center(i1) < _dist_center(_array(behav_pos)))
                goto add_to_container;

        return false;

      add_to_container:
        _array(behav_pos) = i1;
        return true;
    }

    void update(pop_t& offspring, pop_t& parents)
    {
        _update_novelty();
        for (size_t i = 0; i < offspring.size(); i++)
            _update_indiv(offspring[i]);
        for (size_t i = 0; i < parents.size(); i++)
            _update_indiv(parents[i]);
    }

    const array_t& archive() const { return _array; }

    template<class Archive>
    void serialize(Archive & ar, const unsigned int version) {
        ar & BOOST_SERIALIZATION_NVP(_num_filled);
        ar & BOOST_SERIALIZATION_NVP(_array);
    }

  protected:
    // Converts the descriptor into a Point_t
    template <typename I> point_t get_point(const I& indiv) const
    {
        point_t p;
        for (size_t i = 0; i < grid_shape.size(); ++i) {
            assert(indiv->fit().desc()[i] >= 0.0);
            assert(indiv->fit().desc()[i] <= 1.0);
            p[i] = indiv->fit().desc()[i];
        }

        return p;
    }

    template <typename I> double _dist_center(const I& indiv)
    {
        /* Returns distance to center of behavior descriptor cell */
        double dist = 0.0;
        point_t p = get_point(indiv);
        for (size_t i = 0; i < grid_shape.size(); ++i)
            dist += pow(p[i] - (double)round(p[i] * (double)(grid_shape[i] - 1)) / (double)(grid_shape[i] - 1), 2);

        dist = sqrt(dist);
        return dist;
    }

    void _update_novelty()
    {
        // tbb::parallel_for(tbb::blocked_range<indiv_t*>(_array.data(), _array.data() + _array.num_elements()),
                          // [&](const tbb::blocked_range<indiv_t*>& r) {
                              // for (indiv_t* indiv = r.begin(); indiv != r.end(); ++indiv) {
                                  // if (*indiv)
                                      // _update_indiv(*indiv);
                              // }
                          // });
    }

    // Functor to iterate over a Boost MultiArray concept instance.
    template <typename T, typename V, size_t Dimensions = T::dimensionality>
    struct IterateHelper {
        void operator()(T& array, V& vect) const
        {
            for (auto element : array)
                IterateHelper<decltype(element), V>()(element, vect);
        }
    };

    // Functor specialization for the final dimension.
    template <typename T, typename V> struct IterateHelper<T, V, 1> {
        void operator()(T& array, V& vect) const
        {
            for (auto& element : array)
                if (element) vect.push_back(element);
        }
    };

    // Utility function to apply a function to each element of a Boost
    // MultiArray concept instance (which includes views).
    template <typename T, typename V> static void iterate(T& array, V& vect)
    {
        IterateHelper<T, V>()(array, vect);
    }

    // WARNING, individuals in population can be dead...
    void _update_indiv(indiv_t& indiv)
    {
        if (indiv->fit().dead()) {
            indiv->fit().set_novelty(-std::numeric_limits<double>::infinity());
            indiv->fit().set_local_quality(-std::numeric_limits<double>::infinity());
            return;
        }

        int count = 0;
        view_t neighborhood = get_neighborhood(indiv);
        std::vector<indiv_t> neigh;
        iterate(neighborhood, neigh);

        indiv->fit().set_novelty(-(double)neigh.size());
        for (auto& n : neigh)
            if (n->fit().value() < indiv->fit().value())
                count++;

        indiv->fit().set_local_quality(count);
    }

    inline view_t get_neighborhood(indiv_t indiv) const
    {
        behav_index_t ind = get_index(indiv);
        index_gen_t indix;
        int i = 0;
        for (auto it = indix.ranges_.begin(); it != indix.ranges_.end(); it++) {
            *it = index_range_t(std::max((int)ind[i] - (int)nov::deep, 0),
                                std::min(ind[i] + nov::deep + 1, (size_t)grid_shape[i])); // bound! so stop at id[i]+2-1

            i++;
        }

        view_t ngbh = _array[indix];
        return ngbh;
    }

    array_t _array;
    size_t _num_filled = 0;
};

} // namespace container
} // namespace qd
} // namespace sferes

#endif /* end of include guard: SFERES_QD_CONTAINER_GRID_HPP_UNXK1HEF */
