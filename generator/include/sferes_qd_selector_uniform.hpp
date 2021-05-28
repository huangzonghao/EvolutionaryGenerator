#ifndef SFERES_QD_SELECTOR_UNIFORM_HPP_PXRAWHQI
#define SFERES_QD_SELECTOR_UNIFORM_HPP_PXRAWHQI
namespace sferes {
namespace qd {
namespace selector {

// Fill in the shortlist with selected ones from candidates
template <typename Phen>
struct Uniform {
    typedef std::shared_ptr<Phen> indiv_t;

    void operator()(std::vector<indiv_t>& shortlist,
                    const std::vector<indiv_t>& candidates) const
    {
        for (auto& indiv : shortlist)
            indiv = candidates[misc::rand<int>(0, candidates.size())];
    }
};

} // namespace selector
} // namespace qd
} // namespace sferes
#endif /* end of include guard: SFERES_QD_SELECTOR_UNIFORM_HPP_PXRAWHQI */
