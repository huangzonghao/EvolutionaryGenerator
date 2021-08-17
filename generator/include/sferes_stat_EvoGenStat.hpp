#ifndef EVOGEN_GENERATOR_SFERES_STAT_EVOGENSTAT_HPP_
#define EVOGEN_GENERATOR_SFERES_STAT_EVOGENSTAT_HPP_

#include <filesystem>

#include "EvoParams.h"

namespace sferes {
namespace stat {

class EvoGenStat {
  public:
    template <typename E> void make_stat_dir(const E& ea) {
        std::filesystem::create_directory(ea.res_dir() + "/archives");
        if (output_all_robots_)
            std::filesystem::create_directory(ea.res_dir() + "/all_robots");
    }

    template <typename E> void init(const E& ea) {
        if (output_all_robots_)
            _write_init_pop(ea);
        _write_archive(ea);
        _write_progress(ea);
    }

    template <typename E> void refresh(const E& ea) {
        // dump population
        if (output_write_period_ != -1 &&
            ea.gen() % output_write_period_ == 0) {
            if (output_all_robots_)
                _write_offspring(ea);
            _write_archive(ea);
            _write_progress(ea);
        }
    }

    template <typename EA>
    void _write_init_pop(const EA& ea) const {
        std::ofstream ofs(ea.res_dir() + "/all_robots/0.csv");
        size_t idx = 0;
        ofs.precision(5);
        for (auto it = ea.init_pop().begin(); it != ea.init_pop().end(); ++it) {
            ofs << idx << "," << (*it)->fit().value();
            for (size_t dim = 0; dim < (*it)->size(); ++dim)
                ofs << "," << (*it)->data(dim);
            ofs << std::endl;
            ++idx;
        }
        ofs.close();
    }

    template <typename EA>
    void _write_offspring(const EA& ea) const {
        std::string fname = ea.res_dir() + "/all_robots/" + std::to_string(ea.gen() + 1) + ".csv";
        std::ofstream ofs(fname);
        size_t idx = 0;
        ofs.precision(5);
        for (auto it = ea.offspring().begin(); it != ea.offspring().end(); ++it) {
            ofs << idx << "," << (*it)->fit().value();
            for (size_t dim = 0; dim < (*it)->size(); ++dim)
                ofs << "," << (*it)->data(dim);
            ofs << std::endl;
            ++idx;
        }
        ofs.close();
    }

    template <typename EA>
    void _write_archive(const EA& ea) const {
        std::string fname = ea.res_dir() + "/archives/archive_" +
                            std::to_string(ea.gen() + 1) + ".csv";

        std::ofstream ofs(fname);

        size_t idx = 0;
        ofs.precision(5);
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

    template <typename EA>
    void _write_progress(const EA& ea) const {
        std::ofstream ofs(ea.res_dir() + "/progress.txt", std::ofstream::out | std::ofstream::app);
        if (ea.gen() == -1)
            ofs << "Gen, Map size, Gen Time" << std::endl;
        ofs << ea.gen() + 1 << ", " << ea.pop().size() << ", " << ea.last_epoch_time() << std::endl;
        ofs.close();
    }

    void set_params(const EvoParams& evo_params) {
        output_all_robots_ = evo_params.output_all_robots();
        if (evo_params.output_enabled())
            output_write_period_ = evo_params.output_write_period();
        else
            output_write_period_ = -1;
    }

  private:
    bool output_all_robots_ = false;
    size_t output_write_period_ = -1;

}; // EvoGenStat

} // namespace stat
} // namespace sferes

#endif /* end of include guard: EVOGEN_GENERATOR_SFERES_STAT_EVOGENSTAT_HPP_ */
