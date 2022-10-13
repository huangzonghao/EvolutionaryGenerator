#ifndef RAND_HPP_
#define RAND_HPP_

#include <cmath>
#include <cstdlib>
#include <iostream>
#include <list>
#include <random>
#include <stdlib.h>
#include <type_traits>

// a few external tools for seeding (GPL-licensed)
#include "rand_utils.hpp"

namespace sferes {
namespace misc {

using generator_t = std::mt19937;
inline generator_t make_rgen() { return generator_t(randutils::auto_seed_128{}.base()); }

// rand for floating point types (see the dispatcher below)
// this is supposed to generate a number in [min, max)
// but this is not guaranteed in the current implementations
// see notes here: http://en.cppreference.com/w/cpp/numeric/random/uniform_real_distribution
template <typename T>
inline T rand(T min, T max, std::false_type)
{
    assert(max > min);
    static thread_local generator_t rgen = make_rgen();
    std::uniform_real_distribution<T> dist(min, max);
    T v;
    do
        v = dist(rgen);
    while (v >= max);
    assert(v >= min);
    assert(v < max);
    return v;
}

// rand for integral types (see the dispatcher below)
// be careful that uniform_int is in [a,b] but we do [a, b)
// (so that we can use rand(0, list_size))
template <typename T>
inline T rand(T min, T max, std::true_type)
{
    assert(max > min);
    static thread_local generator_t rgen = make_rgen();;
    // uniform_int is in [a,b], not [a,b)...
    std::uniform_int_distribution<size_t> dist(min, max - 1);
    T v = dist(rgen);
    assert(v >= min);
    assert(v < max);
    return v;
}

// the generic rand dispatches between uniform_real and uniform_int
template <typename T>
inline T rand(T min, T max)
{
    return rand(min, max, std::is_integral<T>());
}

template <typename T>
inline T rand(T max = 1.0)
{
    return rand<T>((T)0.0, max);
}

template <typename T>
inline T gaussian_rand(T m = 0.0, T v = 1.0)
{
    static thread_local generator_t rgen = make_rgen();;
    std::normal_distribution<T> dist(m, v);
    return dist(rgen);
}

// randomize indices
inline std::vector<int> randomized_indices(size_t size)
{
    std::vector<int> ids(size);
    for (size_t i = 0; i < ids.size(); ++i)
        ids[i] = i;
    for (size_t i = 0; i < ids.size(); ++i) {
        size_t k = rand(i, ids.size());
        assert(k < ids.size());
        std::swap(ids[i], ids[k]);
    }
    return ids;
}

template<class BidiIter>
BidiIter random_unique(BidiIter begin, BidiIter end, size_t num_random) {
    size_t left = std::distance(begin, end);
    while (num_random--) {
        BidiIter r = begin;
        std::advance(r, std::rand()%left);
        std::swap(*begin, *r);
        ++begin;
        --left;
    }
    return begin;
}

// randomly select m elements from n elements (n >= m).
// using Fisher-Yates shuffle
inline std::vector<int> rand_m_from_n(size_t m, size_t n) {
    std::vector<int> ids(n);
    for (int i = 0; i < n; ++i) ids[i] = i;
    random_unique(ids.begin(), ids.end(), m);
    ids.resize(m);
    return ids;
}

/// return a random it in the list
template <typename T>
inline typename std::list<T>::iterator rand_in_list(std::list<T>& l)
{
    int n = rand((size_t)0, l.size());
    typename std::list<T>::iterator it = l.begin();
    for (int i = 0; i < n; ++i)
        ++it;
    return it;
}

inline bool flip_coin()
{
    static thread_local generator_t rgen = make_rgen();;
    // uniform_int is in [a,b], not [a,b)...
    std::uniform_int_distribution<size_t> dist(0, 1);
    return (dist(rgen) == 0);
}

// todo : remove this
template <typename L>
inline typename L::iterator rand_l(L& l)
{
    int n = rand((size_t)0, l.size());
    typename L::iterator it = l.begin();
    for (int i = 0; i < n; ++i)
        ++it;
    return it;
}

} // namespace misc
} // namespace sferes
#endif
