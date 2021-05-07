#ifndef SFERES_QD_SELECTOR_UNIFORM_HPP_PXRAWHQI
#define SFERES_QD_SELECTOR_UNIFORM_HPP_PXRAWHQI
namespace sferes {
namespace qd {
namespace selector {

// MAP-Elites style: select size(pop) elites
template <typename Phen>
struct Uniform {
    typedef boost::shared_ptr<Phen> indiv_t;

    template <typename EA>
    void operator()(std::vector<indiv_t>& pop, const EA& ea) const
    {
        for (auto& indiv : pop) {
            int x1 = misc::rand<int>(0, ea.pop().size());
            indiv = ea.pop()[x1];
        }
    }
};

} // namespace selector
} // namespace qd
} // namespace sferes
#endif /* end of include guard: SFERES_QD_SELECTOR_UNIFORM_HPP_PXRAWHQI */
