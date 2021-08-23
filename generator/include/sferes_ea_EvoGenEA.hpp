// EA algorithm infrastructure for EvoGen
// This file mainly focuse on setting up the EA structure and do book keeping,
// while the derievd class would focus on and contain only the details of specific
// EA algorithms
#ifndef EVOGEN_GENERATOR_SFERES_EA_EVOGENEA_HPP_
#define EVOGEN_GENERATOR_SFERES_EA_EVOGENEA_HPP_

#include <iostream>
#include <vector>
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

template<typename Phen, typename Eval, typename Stat, typename Exact = stc::Itself>
class EvoGenEA : public stc::Any<Exact> {
  public:
    typedef Phen phen_t;
    typedef Eval eval_t;
    typedef Stat stat_t;
    typedef std::vector<std::shared_ptr<Phen>> pop_t;

    EvoGenEA() {}
    EvoGenEA(const EvoParams& evo_params) : _evo_params(evo_params) {}

    void run(const std::string& exp_name = "") {
        _populate_params();
        _exp_name = exp_name;
        _make_res_dir();
        _set_status("running");
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
        random_pop();
        _dump_state();
        update_stats_init();
        for (_gen = 0; _gen < _nb_gen && !_stop; ++_gen)
            _iter();
        if (!_stop)
            _set_status("finished");
    }

    void resume(const std::string& res_dir, int dump_gen_id) {
        _set_status("resumed");
        _res_dir = res_dir;
        _load_config(_res_dir + "/evo_params.xml");
        _populate_params();
        srand(_evo_params.rand_seed());
        _load_state(_res_dir + "/dumps/gen_" + std::to_string(dump_gen_id) + ".dat");
        _gen = _gen + 1;
        std::cout<<"Resuming at gen: "<< _gen + 1 << std::endl;
        for (; _gen < _nb_gen && !_stop; ++_gen)
            _iter();
        if (!_stop)
            _set_status("finished");
    }

    void random_pop() {
        std::cout << "Gen: 0/" << _nb_gen << " ... ";
        tik = std::chrono::steady_clock::now();
        stc::exact(this)->random_pop();
        time_span = std::chrono::steady_clock::now() - tik;
        _last_epoch_time = time_span.count(); // these two would be booked in stat
        _total_time += _last_epoch_time;
        std::cout << "Done in: " <<  _last_epoch_time << "s. Total: " << _total_time << "s"  << std::endl;
    }

    void epoch() {
        std::cout << "Gen: " << _gen + 1 << "/" << _nb_gen << " ... ";
        tik = std::chrono::steady_clock::now();
        stc::exact(this)->epoch();
        time_span = std::chrono::steady_clock::now() - tik;
        _last_epoch_time = time_span.count(); // these two would be booked in stat
        _total_time += _last_epoch_time;
        std::cout << "Done in: " <<  _last_epoch_time << "s. Total: " << _total_time << "s"  << std::endl;
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
    const eval_t& eval() const { return _eval; }
    eval_t& eval() { return _eval; }

    // ---- stats ---
    const stat_t& stat() const { return _stat; }
    // see issue #47
    stat_t& stat() { return _stat; }

    template<int I>
    const typename boost::fusion::result_of::value_at_c<stat_t, I>::type& stat() const {
        return boost::fusion::at_c<I>(_stat);
    }
    void load(const std::string& fname) { _load_state(fname); }

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

    void stop() {
        _stop = true;
        _set_status("interrupted");
    }
    bool is_stopped() const { return _stop; }

    EvoParams& evo_params() { return _evo_params; }
    void set_params(const EvoParams& evo_params) { _evo_params = evo_params; }

  protected:
    EvoParams _evo_params;
    size_t _nb_gen = 1;
    size_t _progress_dump_period = -1;
    pop_t _pop;
    eval_t _eval;
    stat_t _stat;
    std::string _res_dir;
    int _gen = -1;
    bool _stop = false;
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
        _set_status("running");
    }

    // the status is a file that tells the state of the experiment
    // it is useful to tell to the rest of the world if the experiment has
    // been interrupted
    // typical values: "running", "interrupted", "finished"
    void _set_status(const std::string& status) const {
        if (_progress_dump_period == -1)
            return;
        std::string s = _res_dir + "/status.txt";
        std::ofstream ofs(s.c_str());
        ofs << _gen + 1 << "/" << _nb_gen << " - " << status;
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
        std::ofstream ofs(_res_dir + "/dumps/gen_" + std::to_string(_gen + 1) + ".dat", std::ios::binary);

        boost::archive::binary_oarchive oa(ofs);
        oa << BOOST_SERIALIZATION_NVP(_gen)
           << BOOST_SERIALIZATION_NVP(_last_epoch_time)
           << BOOST_SERIALIZATION_NVP(_total_time)
           << BOOST_SERIALIZATION_NVP(_pop);
        stc::exact(this)->_dump_state_extra(oa);
    }
    void _dump_state_extra(boost::archive::binary_oarchive& oa) const {}
    void _load_state(const std::string& fname) {
        std::ifstream ifs(fname, std::ios::binary);
        if (ifs.fail()) {
            std::cerr << "Cannot open :" << fname
                      << "(does file exist ?)" << std::endl;
            exit(1);
        }
        boost::archive::binary_iarchive ia(ifs);
        ia >> BOOST_SERIALIZATION_NVP(_gen)
           >> BOOST_SERIALIZATION_NVP(_last_epoch_time)
           >> BOOST_SERIALIZATION_NVP(_total_time)
           >> BOOST_SERIALIZATION_NVP(_pop);
        stc::exact(this)->_load_state_extra(ia);
    }
    void _load_state_extra(boost::archive::binary_iarchive& ia) {}
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

#define SFERES_EVOGENEA(Class, Parent)                                                         \
  template<typename Phen, typename Eval, typename Stat, typename Exact = stc::Itself>          \
  class Class : public Parent < Phen, Eval, Stat,                                              \
  typename stc::FindExact<Class<Phen, Eval, Stat, Exact>, Exact>::ret >

// useful to call protected functions of derived classes from the Ea
#define SFERES_EVOGENEA_FRIEND(Class) \
      friend class EvoGenEA< Phen, Eval, Stat,                              \
      typename stc::FindExact<Class<Phen, Eval, Stat, Exact>, Exact>::ret >

#endif /* end of include guard: EVOGEN_GENERATOR_SFERES_EA_EVOGENEA_HPP_ */
