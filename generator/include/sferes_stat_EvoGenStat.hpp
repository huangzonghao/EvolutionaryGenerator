#ifndef EVOGEN_GENERATOR_SFERES_STAT_EVOGENSTAT_HPP_
#define EVOGEN_GENERATOR_SFERES_STAT_EVOGENSTAT_HPP_

#include <filesystem>

#include "EvoParams.h"

namespace sferes {
namespace stat {

class EvoGenStat {
  public:
    template <typename E> void make_stat_dir(const E& ea) {
        std::filesystem::create_directory(ea.res_dir() + "/gridmaps");
        std::filesystem::create_directory(ea.res_dir() + "/gridstats");
        if (output_all_robots_)
            std::filesystem::create_directory(ea.res_dir() + "/robots");
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
        _write_robots_kernel(ea.get_init_pop(), ea.res_dir() + "/robots/0.csv");
    }

    template <typename EA>
    void _write_offspring(const EA& ea) const {
        _write_robots_kernel(ea.offspring(), ea.res_dir() + "/robots/" + std::to_string(ea.gen() + 1) + ".csv");
    }

    template <typename Pop>
    void _write_robots_kernel(const Pop& pop, std::string& output_filename) const {
        std::ofstream ofs(output_filename);
        ofs.precision(5);
        for (auto it = pop.begin(); it != pop.end(); ++it) {
            ofs << (*it)->id().gen << "," << (*it)->id().id << ","
                << (*it)->id().p1_gen << "," << (*it)->id().p1_id << ","
                << (*it)->id().p2_gen << "," << (*it)->id().p2_id << ","
                << (*it)->grid_id()[0] << "," << (*it)->grid_id()[1] << ","
                << (*it)->fit().desc()[0] << "," << (*it)->fit().desc()[1] << ","
                << (*it)->fit().value();

            for (size_t i = 0; i < (*it)->size(); ++i)
                ofs << "," << (*it)->data(i);
            ofs << std::endl;
        }
        ofs.close();
    }

    template <typename EA>
    void _write_archive(const EA& ea) const {
        std::ofstream ofs(ea.res_dir() + "/gridmaps/" + std::to_string(ea.gen() + 1) + ".csv");
        ofs.precision(5);
        for (auto it = ea.pop().begin(); it != ea.pop().end(); ++it) {
            ofs << (*it)->id().gen << "," << (*it)->id().id << ","
                << (*it)->grid_id()[0] << "," << (*it)->grid_id()[1] << ","
                << (*it)->fit().value() << std::endl;
        }
        ofs.close();

        std::ofstream ofs2(ea.res_dir() + "/gridstats/" + std::to_string(ea.gen() + 1) + ".csv");
        const auto& map_stat = ea.container().stat();
        for (int i = 0; i < ea.container().grid_shape[0]; ++i) {
            for (int j = 0; j < ea.container().grid_shape[1]; ++j) {
                ofs2 << map_stat[i][j] << ",";
            }
            ofs2 << std::endl;
        }
        ofs2.close();
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
