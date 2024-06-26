// EA algorithm infrastructure for EvoGen
// This file mainly focuse on setting up the EA structure and do book keeping,
// while the derievd class would focus on and contain only the details of specific
// EA algorithms
#ifndef EVOGEN_GENERATOR_SFERES_EA_EVOGENEA_HPP_
#define EVOGEN_GENERATOR_SFERES_EA_EVOGENEA_HPP_

#include <iostream>
#include <vector>
#include <set>
#include <regex>
#include <fstream>
#include <filesystem>
#include <chrono>

#include <boost/fusion/container.hpp>
#include <boost/fusion/include/for_each.hpp>
#include <boost/archive/binary_oarchive.hpp>
#include <boost/archive/binary_iarchive.hpp>
#include <boost/serialization/shared_ptr.hpp>

#include "stc.hpp"
#include "EvoParams.h"

#ifndef VERSION
#define VERSION "version_unknown"
#endif

namespace sferes {
namespace ea {

template<typename E>
struct RefreshStat_f {
    RefreshStat_f(const E &ea) : _ea(ea) {}
    const E& _ea;
    template<typename T> void operator() (T & x) const { x.refresh(_ea); }
};

template<typename Phen, typename Stat, typename Exact = stc::Itself>
class EvoGenEA : public stc::Any<Exact> {
  public:
    typedef Phen phen_t;
    typedef Stat stat_t;
    typedef std::vector<std::shared_ptr<Phen>> pop_t;

    EvoGenEA() {}
    EvoGenEA(const EvoParams& evo_params) : _evo_params(evo_params) {}

    void run(const std::string& exp_name = "") {
        _populate_params();
        _exp_name = exp_name;
        _make_res_dir();
        size_t rand_seed = _evo_params.rand_seed();
        if (rand_seed == 1) {
            rand_seed = time(0) + ::getpid();
            _evo_params.rand_seed() = rand_seed;
        }
        std::cout<<"Seed: " << rand_seed << std::endl;
        srand(rand_seed);
        std::ofstream ofs;
        ofs.close();
        _dump_config();
        init_pop();
        _dump_state();
        update_stats_init();
        // TODO: update the _gen definitiation so that _gen = 0 is the init_seeds
        //           and the training start with _gen = 1. Otherwise I have to
        //           add 1 to _gen everywhere I use the number.
        for (_gen = 0; _gen < _nb_gen; ++_gen)
            _iter();
    }

    void resume(const std::string& res_dir, int dump_gen_id) {
        _res_dir = res_dir;
        _load_config(_res_dir + "/evo_params.xml");
        _populate_params();
        srand(_evo_params.rand_seed());
        // The stat dump happen before the memory dump at each iteration, so if
        // we can read the memory dump successfully, we are guaranteed to have a
        // complete stat recording for that iteration.
        while (!_load_state(_res_dir + "/dumps/gen_" + std::to_string(dump_gen_id) + ".dat")) {
            // if the initial generation is not completely dumped, just return
            // the whole job and let user manually relaunch it later on. This
            // should be an extremely rare case.
            if (dump_gen_id == 0) {
                return;
            } else {
                dump_gen_id--;
            }
        }
        _gen = _gen + 1;
        std::cout<<"Resuming at gen: "<< _gen + 1 << std::endl;
        for (; _gen < _nb_gen; ++_gen)
            _iter();
    }

    void init_pop() {
        std::cout << "Gen: 0/" << _nb_gen << " ... ";
        tik = std::chrono::steady_clock::now();
        stc::exact(this)->init_pop();
        time_span = std::chrono::steady_clock::now() - tik;
        _last_epoch_time = time_span.count(); // these two would be booked in stat
        _total_time += _last_epoch_time;
        std::cout << "Done in: " <<  _last_epoch_time << "s. Total: " << _total_time << "s" << std::endl;
    }

    void epoch() {
        std::cout << "Gen: " << _gen + 1 << "/" << _nb_gen << " ... ";
        tik = std::chrono::steady_clock::now();
        stc::exact(this)->epoch();
        time_span = std::chrono::steady_clock::now() - tik;
        _last_epoch_time = time_span.count(); // these two would be booked in stat
        _total_time += _last_epoch_time;
        std::cout << "Done in: " <<  _last_epoch_time << "s. Total: " << _total_time << "s" << std::endl;
    }

    // override _set_pop if you want to customize / add treatments
    // (in that case, DO NOT FORGET to add SFERES_EA_FRIEND(YouAlgo);)
    void set_pop(const pop_t& p) {
        _pop = p;
        for (size_t i = 0; i < _pop.size(); ++i)
            _pop[i]->develop();
        stc::exact(this)->_set_pop(p);
    }

    const pop_t& pop() const { return _pop; };
    pop_t& pop() { return _pop; };

    // ---- stats ---
    const stat_t& stat() const { return _stat; }
    // see issue #47
    stat_t& stat() { return _stat; }

    template<int I>
    const typename boost::fusion::result_of::value_at_c<stat_t, I>::type& stat() const {
        return boost::fusion::at_c<I>(_stat);
    }
    bool load(const std::string& fname) { return _load_state(fname); }

    void update_stats_init() {
        boost::fusion::at_c<0>(_stat).init(stc::exact(*this));
    }

    void update_stats() {
        boost::fusion::for_each(_stat, RefreshStat_f<Exact>(stc::exact(*this)));
    }

    const std::string& res_dir() const { return _res_dir; }
    void set_res_dir(const std::string& new_dir) {
        _res_dir = new_dir;
    }
    size_t gen() const { return _gen; }
    void set_gen(unsigned g) { _gen = g; }
    size_t nb_evals() const { return _eval.nb_evals(); }
    bool dump_enabled() const { return _progress_dump_period != -1; }

    EvoParams& evo_params() { return _evo_params; }
    void set_params(const EvoParams& evo_params) { _evo_params = evo_params; }

  protected:
    EvoParams _evo_params;
    size_t _nb_gen = 1;
    size_t _progress_dump_period = -1;
    pop_t _pop;
    stat_t _stat;
    std::string _res_dir;
    int _gen = -1;
    std::string _exp_name;

    std::chrono::steady_clock::time_point tik;
    std::chrono::duration<double> time_span; // in seconds
    double _last_epoch_time = 0;
    double _total_time = 0;

    void _iter() {
        epoch();
        update_stats();
        if (_gen % _progress_dump_period == 0)
            _dump_state();
    }

    template<typename P>
    void _eval_pop(P& p, size_t start = 0, size_t end = 0) {
        if (end == 0)
            end = p.size();
        _eval.eval(p, start, end);
    }
    // override _set_pop if you want to customize / add treatments
    // (in that case, DO NOT FORGET to add SFERES_EA_FRIEND(YouAlgo);)
    void _set_pop(const pop_t& p) {}
    void _make_res_dir() {
        if (_progress_dump_period == -1)
            return;
        if (_res_dir.empty()) {
            time_t t = time(0);
            char time_buffer [80];
            strftime(time_buffer, 80, "%Y%m%d_%H%M%S", localtime(&t));
            _res_dir = std::string(time_buffer) + "_" + std::to_string(::getpid());
            if (!_exp_name.empty())
                _res_dir = _exp_name + "_" + _res_dir;
        }
        std::filesystem::create_directory(_res_dir);
        std::filesystem::create_directory(_res_dir + "/dumps");
        boost::fusion::at_c<0>(_stat).make_stat_dir(*this);
    }
    void _dump_config() const {
        if (_progress_dump_period == -1)
            return;
        _evo_params.Save(_res_dir + "/evo_params.xml");
        stc::exact(this)->_dump_config_extra();
    }
    void _dump_config_extra() const {}
    void _load_config(const std::string& fname) {
        _evo_params.Load(fname);
        stc::exact(this)->_load_config_extra(fname);
    }
    void _load_config_extra(const std::string& fname) {}
    void _dump_state() const {
        if (_progress_dump_period == -1)
            return;
        std::ofstream status_ofs(_res_dir + "/status.txt");
        status_ofs << _gen + 1 << "/" << _nb_gen;

        std::ofstream ofs(_res_dir + "/dumps/gen_" + std::to_string(_gen + 1) + ".dat", std::ios::binary);
        boost::archive::binary_oarchive oa(ofs);
        oa << BOOST_SERIALIZATION_NVP(_gen)
           << BOOST_SERIALIZATION_NVP(_last_epoch_time)
           << BOOST_SERIALIZATION_NVP(_total_time)
           << BOOST_SERIALIZATION_NVP(_pop);
        stc::exact(this)->_dump_state_extra(oa);
        if (_gen % 100 == 0)
            _clean_up_dump_dir(3);
    }
    void _dump_state_extra(boost::archive::binary_oarchive& oa) const {}
    // The init and latest dump is always kept
    // The num_of_dump_to_keep controls how many other latest dumps to keep
    void _clean_up_dump_dir(int num_of_dump_to_keep) const {
        if (num_of_dump_to_keep < 0) {
            num_of_dump_to_keep = 0;
        }
        // sort the dump files in alphabetical order (need to use natural sort)
        //     or by timestamp. The default order of std::filesystem::directory_entry is alphabetic.
        // std::set<std::filesystem::directory_entry> sorted_list;
        // auto compare_by_time = [](std::filesystem::directory_entry e1, std::filesystem::directory_entry e2)
                               // { return e1.last_write_time() < e2.last_write_time(); };
        // std::set<std::filesystem::directory_entry, decltype(compare_by_time)> sorted_list(compare_by_time);
        std::set<std::filesystem::directory_entry, std::function<bool(std::filesystem::directory_entry, std::filesystem::directory_entry)>>
            sorted_list([](std::filesystem::directory_entry e1, std::filesystem::directory_entry e2)
                        { return e1.last_write_time() < e2.last_write_time(); });
        std::regex rx("^gen_([0-9]+).dat");
        for (const auto &entry : std::filesystem::directory_iterator(_res_dir + "/dumps")) {
            if (std::regex_match(std::string(entry.path().filename().string()), rx)) {
                sorted_list.insert(entry);
            }
        }

        if (sorted_list.size() > 2 + num_of_dump_to_keep) {
            int counter = 0;
            for (const auto &entry : sorted_list) {
                // The lastest dump show up the last in the result list
                if (counter > 0 && counter < sorted_list.size() - 1 - num_of_dump_to_keep) {
                    std::filesystem::remove(entry.path());
                }
                ++counter;
            }
        }
    }
    bool _load_state(const std::string& fname) {
        std::ifstream ifs(fname, std::ios::binary);
        if (ifs.fail()) {
            std::cerr << "Cannot open :" << fname
                      << "(does file exist ?)" << std::endl;
            return false;;
        }
        try {
            boost::archive::binary_iarchive ia(ifs);
            ia >> BOOST_SERIALIZATION_NVP(_gen)
                >> BOOST_SERIALIZATION_NVP(_last_epoch_time)
                >> BOOST_SERIALIZATION_NVP(_total_time)
                >> BOOST_SERIALIZATION_NVP(_pop);
            return stc::exact(this)->_load_state_extra(ia);

        } catch (...) {
            std::cerr << "Cannot read :" << fname << std::endl;
            return false;;
        }
    }
    bool _load_state_extra(boost::archive::binary_iarchive& ia) {}
    // TODO: this populate_params thing seems so weird, needs to be removed
    void _populate_params() {
        _nb_gen = _evo_params.nb_gen();
        if (_evo_params.output_enabled())
            _progress_dump_period = _evo_params.progress_dump_period();
        else
            _progress_dump_period = -1;
        boost::fusion::at_c<0>(_stat).set_params(_evo_params);
        stc::exact(this)->_populate_params_extra();
    }
    void _populate_params_extra() {}
};

} // namespace ea
} // namespace sferes

// #define SFERES_EVOGENEA(Class, Parent)                                                         \
  // template<typename Phen, typename Eval, typename Stat, typename Exact = stc::Itself>          \
  // class Class : public Parent < Phen, Eval, Stat,                                              \
  // typename stc::FindExact<Class<Phen, Eval, Stat, Exact>, Exact>::ret >

// // useful to call protected functions of derived classes from the Ea
// #define SFERES_EVOGENEA_FRIEND(Class) \
      // friend class EvoGenEA< Phen, Eval, Stat,                              \
      // typename stc::FindExact<Class<Phen, Eval, Stat, Exact>, Exact>::ret >

#endif /* end of include guard: EVOGEN_GENERATOR_SFERES_EA_EVOGENEA_HPP_ */
