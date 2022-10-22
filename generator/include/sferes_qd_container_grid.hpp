#ifndef EVOGEN_GENERATOR_SFERES_QD_CONTAINER_GRID_HPP_
#define EVOGEN_GENERATOR_SFERES_QD_CONTAINER_GRID_HPP_

// #include <tbb/parallel_for_each.h>
#include <cmath>
#include <boost/archive/binary_oarchive.hpp>
#include <boost/archive/binary_iarchive.hpp>

#include "sferes_phen_EvoGenPhen.hpp"
#include "EvoParams.h"

namespace sferes {
namespace container {
namespace nov { // novelty related settings
    static const size_t deep = 2;
    static const double l = 1;
    static const double k = 8;
    static const double eps = 0.01;
}

class Grid {
  public:
    using indiv_t = std::shared_ptr<sferes::phen::EvoGenPhen>;
    using grid_index_t = std::vector<int>;

    Grid() {}
    Grid(const grid_index_t& grid_shape) { resize(grid_shape); }

    int grid_dim() const { return dimension_; }
    void resize(const grid_index_t& grid_shape) {
        dimension_ = grid_shape.size();
        grid_shape_ = grid_shape;
        num_elements_.resize(dimension_);
        num_elements_[0] = grid_shape_[0];
        for (int i = 1; i < dimension_; ++i)
            num_elements_[i] = num_elements_[i-1] * grid_shape_[i];
        data_.resize(num_elements_.back());
    }
    const std::vector<indiv_t>& vec() const { return data_; }
    indiv_t* data() { return data_.data(); }
    int num_elements() { return num_elements_.back(); }
    indiv_t& operator()(const grid_index_t& grid_idx) {
        return data_[idx_convert(grid_idx)];
    }
    indiv_t& operator[](int idx) {
        return data_[idx];
    }

  private:
    int idx_convert(const grid_index_t& grid_idx) {
        int idx = grid_idx[0];
        for (int i = 1; i < dimension_; ++i) {
            idx += grid_idx[i] * num_elements_[i-1];
        }
        return idx;
    }
    grid_index_t idx_convert(int idx) {
        grid_index_t grid_idx(dimension_);
        grid_idx[0] = idx % num_elements_[0];
        idx -= grid_idx[0];
        for (int i = 1; i < dimension_; ++i) {
            grid_idx[i] = idx % num_elements_[i];
            idx -= grid_idx[i] * num_elements_[i-1];
        }
        return grid_idx;
    }
    int dimension_ = 0;
    std::vector<int> grid_shape_;
    std::vector<int> num_elements_; // num_elements of each level.
                                    // num_elements_[0] = grid_shape_[0]
                                    // num_elements_[1] = grid_shape_[0] * grid_shape_[1]
                                    // num_elements_.back() is the total number of elements of the entire container
    std::vector<indiv_t> data_;
};

class EvoGenArchiveContainer {
  public:
    typedef std::shared_ptr<sferes::phen::EvoGenPhen> indiv_t;
    typedef std::vector<indiv_t> pop_t;
    typedef std::vector<int> index_t;
    typedef std::vector<double> point_t;

    // TODO: re-enable stat recording
    EvoGenArchiveContainer() {
        // _stat.resize(_grid_shape);
        // reset_stat();
    }

    // void reset_stat() {
        // for (int *it = _stat.origin(); it != _stat.origin() + _stat.num_elements(); ++it)
            // *it = 0;
    // }

    void set_params(const EvoParams& evo_params) {
        _grid_shape = evo_params.grid_shape();
        if (_grid_shape.size() > 0) {
            _grid.resize(_grid_shape);
        } else {
            std::cout << "Grid Map with dimension " << _grid_shape.size() << "not implemented" << std::endl;
            exit(1);
        }
        // _stat.resize(_grid_shape);
    }

    index_t get_index(const indiv_t& indiv) const {
        const auto& p = get_point(indiv);
        index_t behav_pos(_grid.grid_dim());
        for (int i = 0; i < _grid.grid_dim(); ++i) {
            behav_pos[i] = round(p[i] * (_grid_shape[i] - 1));
            assert(behav_pos[i] < _grid_shape[i]);
        }
        return behav_pos;
    }

    void get_full_content(std::vector<indiv_t>& container) const {
        container.resize(_num_filled);
        int counter = 0;
        for (const auto& ind : _grid.vec()) {
            if (ind) container[counter++] = ind;
        }
        assert(counter == _num_filled);
    }

    bool add(indiv_t i1) {
        if (i1->fit().dead())
            return false;

        index_t behav_pos = get_index(i1);

        const double epsilon = 0.00;
        if (!_grid(behav_pos)) {
            _num_filled++;
            goto add_to_container;
        }
        if (i1->fit().value() - _grid(behav_pos)->fit().value() > epsilon)
            goto add_to_container;
        // TODO: why?
        // same fitness but the features are closer to the center of map
        if (std::abs(i1->fit().value() - _grid(behav_pos)->fit().value()) <= epsilon &&
            _dist_center(i1) < _dist_center(_grid(behav_pos)))
                goto add_to_container;

        return false;

      add_to_container:
        i1->set_grid_id(behav_pos);
        _grid(behav_pos) = i1;
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

    // const Grid& archive() const { return _grid; }
    // const stat_t& stat() const { return _stat; }

  protected:
    // TODO: the way it converts double to int seems to be different from what
    //           I have been using
    // Converts the descriptor into a point
    // Ignoring the rest of data in descriptor
    point_t get_point(const indiv_t& indiv) const {
        point_t p(_grid.grid_dim());
        for (size_t i = 0; i < _grid.grid_dim(); ++i) {
            assert(indiv->fit().desc()[i] >= 0.0);
            assert(indiv->fit().desc()[i] <= 1.0);
            p[i] = indiv->fit().desc()[i];
        }
        return p;
    }

    double _dist_center(const indiv_t& indiv) {
        /* Returns distance to center of behavior descriptor cell */
        double dist = 0.0;
        const auto& p = get_point(indiv);
        for (size_t i = 0; i < _grid.grid_dim(); ++i)
            dist += pow(p[i] - (double)round(p[i] * (double)(_grid_shape[i] - 1)) / (double)(_grid_shape[i] - 1), 2);

        dist = sqrt(dist);
        return dist;
    }

    void _update_novelty() {
        // tbb::parallel_for(tbb::blocked_range<indiv_t*>(_grid.data(), _grid.data() + _grid.num_elements()),
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

        // TODO: Need to re-enable novelty in the future. But right now I am
        // not sure how to use them
        // int count = 0;
        // view_t neighborhood = get_neighborhood(indiv);
        // std::vector<indiv_t> neigh;
        // iterate(neighborhood, neigh); // convert a boost multiarray to std::vector

        // indiv->fit().set_novelty(-(double)neigh.size()); // the more neighbors you have, the less novel you are
        // for (auto& n : neigh)
            // if (n->fit().value() < indiv->fit().value())
                // count++;

        // indiv->fit().set_local_quality(count);
    }

    // TODO: figure what nov::deep is doing here
    // inline view_t get_neighborhood(indiv_t indiv) const {
        // index_t ind = get_index(indiv);
        // index_gen_t indix;
        // int i = 0;
        // for (auto it = indix.ranges_.begin(); it != indix.ranges_.end(); it++) {
            // *it = int(std::max((int)ind[i] - (int)nov::deep, 0),
                      // std::min(ind[i] + nov::deep + 1, (size_t)_grid_shape[i])); // bound! so stop at id[i]+2-1

            // i++;
        // }

        // view_t ngbh = _grid[indix];
        // return ngbh;
    // }

    index_t _grid_shape;
    Grid _grid;
    // stat stores the number of times that each bin is updated
    // TODO: need to store it as sparse matrix instead of a condesed matrix,
    // especially when the offspring size is small and grid map is large.
    // stat_t _stat;
    size_t _num_filled = 0;
};

} // namespace container
} // namespace sferes

#endif /* end of include guard: EVOGEN_GENERATOR_SFERES_QD_CONTAINER_GRID_HPP_ */
