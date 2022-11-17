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
        // std::filesystem::create_directory(ea.res_dir() + "/gridstats");
        // Version 2.0 -- Adjusted the order of gridmap recording. Now fitness shows
        //     in front of descriptor/grid_id to allow different grid_id dimensions
        std::ofstream ofs(ea.res_dir() + "/version.txt");
        ofs << "2.0" << std::endl;
        ofs.close();
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
    void _write_robots_kernel(const Pop& pop, const std::string& output_filename) const {
        std::ofstream ofs(output_filename);
        ofs.precision(5);
        for (auto it = pop.begin(); it != pop.end(); ++it) {
            ofs << (*it)->id().gen << "," << (*it)->id().id << "," // 1, 2
                << (*it)->id().p1_gen << "," << (*it)->id().p1_id << "," // 3, 4
                << (*it)->id().p2_gen << "," << (*it)->id().p2_id << "," // 5, 6
                << (*it)->fit().value << ","; // 7
            for (const auto& id : (*it)->grid_id()) ofs << id << ",";
            for (const auto& desc : (*it)->fit().desc) ofs << desc << ",";
            for (const auto& gene : (*it)->data()) ofs << gene << ",";
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
                << (*it)->fit().value << ",";
            for (const auto& id : (*it)->grid_id()) ofs << id << ",";
            ofs << std::endl;
        }
        ofs.close();

        // std::ofstream ofs2(ea.res_dir() + "/gridstats/" + std::to_string(ea.gen() + 1) + ".csv");
        // const auto& map_stat = ea.container().stat();
        // for (int i = 0; i < ea.container().grid_shape[0]; ++i) {
            // for (int j = 0; j < ea.container().grid_shape[1]; ++j) {
                // ofs2 << map_stat[i][j] << ",";
            // }
            // ofs2 << std::endl;
        // }
        // ofs2.close();
    }

    template <typename EA>
    void _write_progress(const EA& ea) const {
        std::ofstream ofs(ea.res_dir() + "/progress.txt", std::ofstream::out | std::ofstream::app);
        if (ea.gen() == -1)
            ofs << "Gen, Map size, Num Valid/Total Robots, Gen Time" << std::endl;
        ofs << ea.gen() + 1 << ", " << ea.pop().size() << ", "
            << ea.num_valid_robots_last_batch() << "/" << ea.gen_pop_size() << ", "
            << ea.last_epoch_time() << std::endl;
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
