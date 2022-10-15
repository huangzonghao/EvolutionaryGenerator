#ifndef EVOGEN_GENERATOR_SFERES_QD_CONTAINER_GRID_HPP_
#define EVOGEN_GENERATOR_SFERES_QD_CONTAINER_GRID_HPP_

// #include <tbb/parallel_for_each.h>
#include <cmath>
#include <boost/multi_array.hpp>
#include <boost/archive/binary_oarchive.hpp>
#include <boost/archive/binary_iarchive.hpp>

#include "EvoParams.h"

namespace sferes {
namespace qd {
namespace container {

namespace nov { // novelty related settings
    static const size_t deep = 2;
    static const double l = 1;
    static const double k = 8;
    static const double eps = 0.01;
}

template <typename Phen>
class Grid {
  public:
    // TODO: see how to get dim and gridshape to a configurable parameter
    // The main obstacle seems to be the boost::multi_aray
    // static const size_t dim = 4;
    static const size_t dim = 2;
    typedef std::shared_ptr<Phen> indiv_t;
    typedef typename std::vector<indiv_t> pop_t;
    typedef typename pop_t::iterator it_t;
    typedef typename std::vector<std::vector<indiv_t>> front_t;

    typedef boost::multi_array<indiv_t, dim> map_t;
    typedef boost::multi_array<int, dim> stat_t;
    typedef typename map_t::multi_array_base::index_range index_range_t;
    typedef boost::detail::multi_array::index_gen<dim, dim> index_gen_t;
    typedef typename map_t::template const_array_view<dim>::type view_t;
    // TODO: convert this thing to vector
    using behav_index_t = std::vector<int>;
    typedef std::array<double, dim> point_t;

    // TODO: make sure all behav_index_t works
    behav_index_t grid_shape;
    int grid_dim = 2;

    // TODO: re-enable stat recording
    Grid() {
        // _stat.resize(grid_shape);
        // reset_stat();
    }

    // void reset_stat() {
        // for (int *it = _stat.origin(); it != _stat.origin() + _stat.num_elements(); ++it)
            // *it = 0;
    // }

    // Set parameters seem to be called only when resuming?
    // Not during initialization?
    void set_params(const EvoParams& evo_params) {
        grid_shape = evo_params.grid_shape();
        grid_dim = grid_shape.size();
        // allocate space for _array and _array_parents
        _array.resize(grid_shape);
        // _stat.resize(grid_shape);
    }

    template <typename I> behav_index_t get_index(const I& indiv) const {
        point_t p = get_point(indiv);
        behav_index_t behav_pos(grid_dim);
        for (int i = 0; i < grid_dim; ++i) {
            behav_pos[i] = round(p[i] * (grid_shape[i] - 1));
            assert(behav_pos[i] < grid_shape[i]);
        }
        return behav_pos;
    }

    void get_full_content(std::vector<indiv_t>& container) const {
        container.resize(_num_filled);
        int counter = 0;
        for (const indiv_t* ind = _array.data(); ind < (_array.data() + _array.num_elements()); ++ind)
            if (*ind) container[counter++] = *ind;

        assert(counter == _num_filled);
    }

    bool add(indiv_t i1) {
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
        i1->set_grid_id(behav_pos);
        _array(behav_pos) = i1;
        // _stat(behav_pos) += 1;
        return true;
    }

    void update(pop_t& offspring, pop_t& parents) {
        _update_novelty();
        for (size_t i = 0; i < offspring.size(); i++)
            _update_indiv(offspring[i]);
        for (size_t i = 0; i < parents.size(); i++)
            _update_indiv(parents[i]);
    }

    const map_t& archive() const { return _array; }
    // const stat_t& stat() const { return _stat; }

    template<class Archive>
    void serialize(Archive & ar, const unsigned int version) {
        ar & BOOST_SERIALIZATION_NVP(_num_filled);
        ar & BOOST_SERIALIZATION_NVP(_array);
        // ar & BOOST_SERIALIZATION_NVP(_stat);
    }

  protected:
    // TODO: the way it converts double to int seems to be different from what
    //           I have been using
    // Converts the descriptor into a Point_t
    // Ignoring the rest of data in descriptor
    template <typename I> point_t get_point(const I& indiv) const {
        point_t p;
        for (size_t i = 0; i < grid_dim; ++i) {
            assert(indiv->fit().desc()[i] >= 0.0);
            assert(indiv->fit().desc()[i] <= 1.0);
            p[i] = indiv->fit().desc()[i];
        }

        return p;
    }

    template <typename I> double _dist_center(const I& indiv) {
        /* Returns distance to center of behavior descriptor cell */
        double dist = 0.0;
        point_t p = get_point(indiv);
        for (size_t i = 0; i < grid_dim; ++i)
            dist += pow(p[i] - (double)round(p[i] * (double)(grid_shape[i] - 1)) / (double)(grid_shape[i] - 1), 2);

        dist = sqrt(dist);
        return dist;
    }

    void _update_novelty() {
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
    void _update_indiv(indiv_t& indiv) {
        if (indiv->fit().dead()) {
            indiv->fit().set_novelty(-std::numeric_limits<double>::infinity());
            indiv->fit().set_local_quality(-std::numeric_limits<double>::infinity());
            return;
        }

        int count = 0;
        view_t neighborhood = get_neighborhood(indiv);
        std::vector<indiv_t> neigh;
        iterate(neighborhood, neigh); // convert a boost multiarray to std::vector

        indiv->fit().set_novelty(-(double)neigh.size()); // the more neighbors you have, the less novel you are
        for (auto& n : neigh)
            if (n->fit().value() < indiv->fit().value())
                count++;

        indiv->fit().set_local_quality(count);
    }

    // TODO: figure what nov::deep is doing here
    inline view_t get_neighborhood(indiv_t indiv) const {
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

    map_t _array;
    // stat stores the number of times that each bin is updated
    // TODO: need to store it as sparse matrix instead of a condesed matrix,
    // especially when the offspring size is small and grid map is large.
    // stat_t _stat;
    size_t _num_filled = 0;
};

} // namespace container
} // namespace qd
} // namespace sferes

#endif /* end of include guard: EVOGEN_GENERATOR_SFERES_QD_CONTAINER_GRID_HPP_ */
