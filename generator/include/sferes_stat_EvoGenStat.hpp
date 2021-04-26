#ifndef SFERES_STAT_EVOGENSTAT_HPP_HQ1F0APZ
#define SFERES_STAT_EVOGENSTAT_HPP_HQ1F0APZ

#include <numeric>
#include <sferes/stat/stat.hpp>

namespace sferes {
namespace stat {

SFERES_STAT(EvoGenStat, Stat){
  public:
    typedef std::vector<boost::shared_ptr<Phen> > archive_t;

    template <typename E> void refresh(const E& ea) {
        _container.clear();
        for (auto it = ea.pop().begin(); it != ea.pop().end(); ++it)
            _container.push_back(*it);

        if (ea.gen() % Params::pop::evogen_dump_period == 0)
            _write_container(std::string("archive_"), ea);

        // if (ea.gen() == Params::pop::nb_gen - 1) {
        // }
    }

    template <typename EA>
    void _write_container(const std::string& prefix, const EA& ea) const {
        std::string fname = ea.res_dir() + "/archives/" + prefix
            + boost::lexical_cast<std::string>(ea.gen() + 1) + std::string(".csv");

        std::ofstream ofs(fname);

        size_t idx = 0;
        ofs.precision(17);
        for (auto it = ea.pop().begin(); it != ea.pop().end(); ++it) {
            ofs << idx << ",";
            for (size_t dim = 0; dim < (*it)->fit().desc().size(); ++dim)
                ofs << (*it)->fit().desc()[dim] << ",";
            ofs << (*it)->fit().value();

            for (size_t dim = 0; dim < (*it)->size(); ++dim)
                ofs << "," << (*it)->data(dim);
            ofs << std::endl;
            ++idx;
        }
        ofs.close();
    }

    template<class Archive>
    void serialize(Archive & ar, const unsigned int version) {
        ar & BOOST_SERIALIZATION_NVP(_container);
    }

    const archive_t& archive() const { return _container; }

  protected:
    archive_t _container;
}; // EvoGenStat

} // namespace stat
} // namespace sferes

#endif /* end of include guard: SFERES_STAT_EVOGENSTAT_HPP_HQ1F0APZ */
