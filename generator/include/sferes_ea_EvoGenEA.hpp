// EA algorithm infrastructure for EvoGen
// This file mainly focuse on setting up the EA structure and do book keeping,
// while the derievd class would focus on and contain only the details of specific
// EA algorithms
#ifndef SFERES_EA_EVOGENEA_HPP_IKZHM4BW
#define SFERES_EA_EVOGENEA_HPP_IKZHM4BW
#include <iostream>
#include <vector>
#include <fstream>
#include <filesystem>
#include <chrono>

#include <boost/fusion/container.hpp>
#include <boost/fusion/algorithm.hpp>
#include <boost/mpl/vector.hpp>
#include <boost/fusion/support/is_sequence.hpp>
#include <boost/fusion/include/is_sequence.hpp>
#include <boost/fusion/algorithm/iteration/for_each.hpp>
#include <boost/fusion/include/for_each.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/archive/binary_oarchive.hpp>
#include <boost/archive/binary_iarchive.hpp>
#include <boost/mpl/joint_view.hpp>

#include <sferes/dbg/dbg.hpp>
#include <sferes/misc.hpp>
#include <sferes/stc.hpp>
#include <sferes/stat/state.hpp>

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

template<typename A>
struct WriteStat_f {
    WriteStat_f(A & a) : _archive(a) {}
    A& _archive;
    template<typename T> void operator() (const T &x) const {
        std::string version(VERSION);
        _archive << boost::serialization::make_nvp("version", version);
        _archive << BOOST_SERIALIZATION_NVP(x);
    }
};

template<typename A>
struct ReadStat_f {
    ReadStat_f(A & a) : _archive(a) {}
    A& _archive;
    template<typename T> void operator() (T & x) const {
        std::string version;
        _archive >> boost::serialization::make_nvp("version", version);
        if (version != std::string(VERSION))
            std::cerr << "WARNING: your are loading a file made with sferes version "
                      << version << " while the current version is:" << VERSION << std::endl;
        _archive >> BOOST_SERIALIZATION_NVP(x);
    }
};

struct ShowStat_f {
    ShowStat_f(unsigned n, std::ostream & os, size_t k) : _n(n), _i(0), _os(os), _k(k) {}
    template<typename T> void operator() (T & x) const {
        if (_i == _n)
            x.show(_os, _k);
        ++_i;
    }
    int _n;
    mutable int _i;
    std::ostream& _os;
    size_t _k;
};

template<typename E>
struct ApplyModifier_f {
    ApplyModifier_f(E &ea) : _ea(ea) {}
    E& _ea;
    template<typename T> void operator() (T & x) const { x.apply(_ea); }
};

// we need this to resume only if there is a state
// (and we need to be able to compile without a State)
template<typename T, typename S>
struct Resume {
    template<typename EA>
    void resume(EA& ea) {
        typedef stat::State<typename EA::phen_t, typename EA::params_t>  state_t;
        const state_t& s = *boost::fusion::find<state_t>(ea.stat());
        ea.set_gen(s.gen() + 1);
        ea.set_pop(s.pop());
    }
};

// do nothing if there is no state
template<typename T>
struct Resume<T, typename boost::fusion::result_of::end<T>::type> {
    template<typename EA> void resume(EA& ea) {}
};

template<typename Phen, typename Eval, typename Stat, typename FitModifier,
         typename Params, typename Exact = stc::Itself>
class EvoGenEA : public stc::Any<Exact> {
  public:
    typedef Phen phen_t;
    typedef Eval eval_t;
    typedef Params params_t;

    typedef Stat stat_t;

    typedef typename
    boost::mpl::if_<boost::fusion::traits::is_sequence<FitModifier>,
                    FitModifier, boost::fusion::vector<FitModifier> >::type modifier_t;
    typedef std::vector<boost::shared_ptr<Phen> > pop_t;
    typedef typename phen_t::fit_t fit_t;

    EvoGenEA() : _pop(), _gen(-1), _stop(false) {}

    void set_fit_proto(const fit_t& fit) { _fit_proto = fit; }

    void run(const std::string& exp_name = "") {
        dbg::trace trace("ea", DBG_HERE);
        _exp_name = exp_name;
        _make_res_dir();
        _set_status("running");
        if (_rand_seed == 1)
            _rand_seed = time(0) + ::getpid();
        std::cout<<"Seed: " << _rand_seed << std::endl;
        srand(_rand_seed);
        std::ofstream ofs;
        ofs.open(_res_dir + "/progress.txt");
        ofs << "Seed: " << _rand_seed << std::endl;
        ofs.close();
        // TODO: config and params should ultimately be the same file
        // Need to convert Params to a regular class first
        _dump_config();
        Params::Save(_res_dir + "/params.csv");
        random_pop();
        _dump_state();
        update_stats_init();
        for (_gen = 0; _gen < Params::pop::nb_gen && !_stop; ++_gen)
            _iter();
        if (!_stop)
            _set_status("finished");
    }

    void resume(const std::string& fname) {
        dbg::trace trace("ea", DBG_HERE);
        _set_status("resumed");
        std::filesystem::path fpath(fname);
        _load_config(fpath.parent_path().string() + "/config.dat");
        srand(_rand_seed);
        _load_state(fname);
        _gen = _gen + 1;
        std::cout<<"resuming at:"<< _gen + 1 << std::endl;
        for (; _gen < Params::pop::nb_gen && !_stop; ++_gen)
            _iter();
        if (!_stop)
            _set_status("finished");
    }

    void random_pop() {
        std::cout << "Gen: 0/" << Params::pop::nb_gen << " ... ";
        tik = std::chrono::steady_clock::now();
        dbg::trace trace("ea", DBG_HERE);
        stc::exact(this)->random_pop();
        time_span = std::chrono::steady_clock::now() - tik;
        _last_epoch_time = time_span.count(); // these two would be booked in stat
        _total_time += _last_epoch_time;
        std::cout << "Done in: " <<  _last_epoch_time << "s. Total: " << _total_time << "s"  << std::endl;
    }

    void epoch() {
        std::cout << "Gen: " << _gen + 1 << "/" << Params::pop::nb_gen << " ... ";
        tik = std::chrono::steady_clock::now();
        dbg::trace trace("ea", DBG_HERE);
        stc::exact(this)->epoch();
        time_span = std::chrono::steady_clock::now() - tik;
        _last_epoch_time = time_span.count(); // these two would be booked in stat
        _total_time += _last_epoch_time;
        std::cout << "Done in: " <<  _last_epoch_time << "s. Total: " << _total_time << "s"  << std::endl;
    }

    // override _set_pop if you want to customize / add treatments
    // (in that case, DO NOT FORGET to add SFERES_EA_FRIEND(YouAlgo);)
    void set_pop(const pop_t& p) {
        dbg::trace trace("ea", DBG_HERE);
        this->_pop = p;
        for (size_t i = 0; i < this->_pop.size(); ++i)
            this->_pop[i]->develop();
        stc::exact(this)->_set_pop(p);
    }

    const pop_t& pop() const { return _pop; };
    pop_t& pop() { return _pop; };
    const eval_t& eval() const { return _eval; }
    eval_t& eval() { return _eval; }

    //---- modifiers ----
    const modifier_t& fit_modifier() const { return _fit_modifier; }

    template<int I>
    const typename boost::fusion::result_of::value_at_c<modifier_t, I>::type& fit_modifier() const {
        return boost::fusion::at_c<I>(_fit_modifier);
    }

    void apply_modifier() {
        boost::fusion::for_each(_fit_modifier, ApplyModifier_f<Exact>(stc::exact(*this)));
    }

    // ---- stats ---
    const stat_t& stat() const { return _stat; }
    // see issue #47
    stat_t& stat() { return _stat; }

    template<int I>
    const typename boost::fusion::result_of::value_at_c<stat_t, I>::type& stat() const {
        return boost::fusion::at_c<I>(_stat);
    }
    void load(const std::string& fname) { _load_state(fname); }

    void show_stat(unsigned i, std::ostream& os, size_t k = 0) {
        boost::fusion::for_each(_stat, ShowStat_f(i, os, k));
    }

    void update_stats_init() {
        boost::fusion::at_c<0>(_stat).init(stc::exact(*this));
    }

    void update_stats() {
        boost::fusion::for_each(_stat, RefreshStat_f<Exact>(stc::exact(*this)));
    }

    const std::string& res_dir() const { return _res_dir; }
    void set_res_dir(const std::string& new_dir) {
        _res_dir = new_dir;
        _make_res_dir();
    }
    size_t gen() const { return _gen; }
    void set_gen(unsigned g) { _gen = g; }
    size_t nb_evals() const { return _eval.nb_evals(); }
    bool dump_enabled() const { return Params::pop::dump_period != -1; }
    size_t rand_seed() const { return _rand_seed; }
    void set_rand_seed(size_t randseed) { _rand_seed = randseed; }

    void stop() {
        _stop = true;
        _set_status("interrupted");
    }
    bool is_stopped() const { return _stop; }

  protected:
    pop_t _pop;
    eval_t _eval;
    stat_t _stat;
    fit_t _fit_proto;
    modifier_t _fit_modifier;
    std::string _res_dir;
    size_t _gen;
    bool _stop;
    std::string _exp_name;
    size_t _rand_seed = 1;

    std::chrono::steady_clock::time_point tik;
    std::chrono::duration<double> time_span; // in seconds
    double _last_epoch_time = 0;
    double _total_time = 0;

    void _iter() {
        epoch();
        update_stats();
        if (_gen % Params::pop::dump_period == 0)
            _dump_state();
    }

    // the status is a file that tells the state of the experiment
    // it is useful to tell to the rest of the world if the experiment has
    // been interrupted
    // typical values: "running", "interrupted", "finished"
    void _set_status(const std::string& status) const {
        std::string s = _res_dir + "/status.txt";
        std::ofstream ofs(s.c_str());
        ofs << status;
    }

    template<typename P>
    void _eval_pop(P& p, size_t start, size_t end) {
        dbg::trace trace("ea", DBG_HERE);
        this->_eval.eval(p, start, end, this->_fit_proto);
    }
    // override _set_pop if you want to customize / add treatments
    // (in that case, DO NOT FORGET to add SFERES_EA_FRIEND(YouAlgo);)
    void _set_pop(const pop_t& p) { dbg::trace trace("ea", DBG_HERE); }
    void _make_res_dir() {
        dbg::trace trace("ea", DBG_HERE);
        if (_res_dir.empty()) {
            if (_exp_name.empty())
            _res_dir = misc::date() + "_" + misc::getpid();
            else
            _res_dir = _exp_name + "_" + misc::date() + "_" + misc::getpid();
        }
        std::filesystem::create_directory(_res_dir);
        std::filesystem::create_directory(_res_dir + "/dumps");
        boost::fusion::at_c<0>(_stat).make_stat_dir(*this);
    }
    void _dump_config() const {
        dbg::trace trace("ea", DBG_HERE);
        std::ofstream ofs(_res_dir + "/dumps/config.dat", std::ios::binary);

        boost::archive::binary_oarchive oa(ofs);
        oa << BOOST_SERIALIZATION_NVP(_rand_seed)
           << BOOST_SERIALIZATION_NVP(_res_dir);
    }
    void _load_config(const std::string& fname) {
        dbg::trace trace("ea", DBG_HERE);
        std::ifstream ifs(fname, std::ios::binary);
        if (ifs.fail()) {
            std::cerr << "Cannot open :" << fname
                      << "(does file exist ?)" << std::endl;
            exit(1);
        }
        boost::archive::binary_iarchive ia(ifs);
        ia >> BOOST_SERIALIZATION_NVP(_rand_seed)
           >> BOOST_SERIALIZATION_NVP(_res_dir);
    }
    void _dump_state() const {
        dbg::trace trace("ea", DBG_HERE);
        if (Params::pop::dump_period == -1)
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
        dbg::trace trace("ea", DBG_HERE);
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
};

} // namespace ea
} // namespace sferes

#define SFERES_EVOGENEA(Class, Parent)                                                         \
  template<typename Phen, typename Eval, typename Stat, typename FitModifier, typename Params, \
           typename Exact = stc::Itself>                                                       \
  class Class : public Parent < Phen, Eval, Stat, FitModifier, Params,                         \
  typename stc::FindExact<Class<Phen, Eval, Stat, FitModifier, Params, Exact>, Exact>::ret >

// useful to call protected functions of derived classes from the Ea
#define SFERES_EVOGENEA_FRIEND(Class) \
      friend class EvoGenEA< Phen, Eval, Stat, FitModifier, Params,                         \
      typename stc::FindExact<Class<Phen, Eval, Stat, FitModifier, Params, Exact>, Exact>::ret >

#endif /* end of include guard: SFERES_EA_EVOGENEA_HPP_IKZHM4BW */
