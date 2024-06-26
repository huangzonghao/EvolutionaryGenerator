// QD algorithm for EvoGen
#ifndef EVOGEN_GENERATOR_SFERES_QD_EVOGENQD_HPP_
#define EVOGEN_GENERATOR_SFERES_QD_EVOGENQD_HPP_

#include <filesystem>
#include <boost/archive/binary_oarchive.hpp>
#include <boost/archive/binary_iarchive.hpp>

#include "stc.hpp"
#include "sferes_ea_EvoGenEA.hpp"
#include "EvoParams.h"
#include "SimulatorParams.h"

namespace sferes {
namespace qd {

// Main class
template <typename Phen, typename Eval, typename Stat, typename Selector,
          typename Container, typename Exact = stc::Itself>
class EvoGenQD
    : public ea::EvoGenEA<Phen, Stat,
            typename stc::FindExact<EvoGenQD<Phen, Eval, Stat, Selector,
                                             Container, Exact>, Exact>::ret> {
  public:
    typedef typename stc::FindExact<EvoGenQD<Phen, Eval, Stat, Selector, Container, Exact>,
                                    Exact>::ret exact_t;
    typedef Phen phen_t;
    typedef Eval eval_t;
    typedef std::shared_ptr<Phen> indiv_t;
    typedef typename std::vector<indiv_t> pop_t;

    friend class ea::EvoGenEA<Phen, Stat, exact_t>;

    // Note the default constructor should only be used when resuming.
    // The member structs are incomplete without proper calls of set_params.
    EvoGenQD() {}
    EvoGenQD(const EvoParams& evo_params, const SimulatorParams& sim_params)
        : ea::EvoGenEA<Phen, Stat, exact_t>(evo_params), _sim_params(sim_params)
    {
        this->_eval.init(_evo_params, _sim_params);
        // TODO: dereference the runtime polymorphism here
        this->_container.set_params(_evo_params);
    }

    void _eval_pop(pop_t& pop, size_t start = 0, size_t end = 0) {
        if (end == 0)
            end = pop.size();
        _eval.eval(pop, start, end);
    }
    const eval_t& eval() const { return _eval; }
    eval_t& eval() { return _eval; }
    size_t nb_evals() const { return _eval.nb_evals(); }
    const Container& container() const { return _container; }
    const pop_t& offspring() const { return _offspring; }
    pop_t& offspring() { return _offspring; }
    const pop_t& parents() const { return _parents; }
    pop_t& parents() { return _parents; }
    const pop_t& get_init_pop() const { return _init_pop; }
    const std::vector<bool>& added() const { return _added; }
    std::vector<bool>& added() { return _added; }
    const double last_epoch_time() const { return  this->_last_epoch_time; }
    const int num_valid_robots_last_batch() const { return _eval.num_valids(); }
    const int gen_pop_size() const { return _pop_size; }
    void set_init_seeds(const std::shared_ptr<std::vector<std::vector<double>>>& new_seeds) { _init_seeds = new_seeds; }

    void init_pop() {
        assert(_init_size != 0);
        _init_pop.clear();

        // Feed in user seeds if exist
        if (_init_seeds) {
            int num_seeds_to_load = 0;
            switch (this->_evo_params.input_sampling) {
            case EvoParams::UserDesignSampling::RANDOM:
                num_seeds_to_load = this->_evo_params.num_user_inputs;
                if (num_seeds_to_load <= _init_seeds->size()) {
                    const std::vector<int>& init_seed_idx = misc::rand_m_from_n(num_seeds_to_load, _init_seeds->size());
                    for (int i = 0; i < num_seeds_to_load; ++i) {
                        _init_pop.emplace_back(std::make_shared<Phen>(_init_seeds->at(init_seed_idx[i]), this->_evo_params));
                        _init_pop.back()->set_id(0, i);
                    }
                } else {
                    // copy all seeds to shortlist
                    for (int i = 0; i < _init_seeds->size(); ++i) {
                        _init_pop.emplace_back(std::make_shared<Phen>(_init_seeds->at(i), this->_evo_params));
                        _init_pop.back()->set_id(0, i);
                    }
                }
                break;
            case EvoParams::UserDesignSampling::ALL:
            default:
                // Allowing overfill of user seeds
                // int num_seeds_to_load = std::min(_init_size, _init_seeds->size());
                num_seeds_to_load = _init_seeds->size();
                for (int i = 0; i < num_seeds_to_load; ++i) {
                    _init_pop.emplace_back(std::make_shared<Phen>(_init_seeds->at(i), this->_evo_params));
                    _init_pop.back()->set_id(0, i);
                }
            }
        }

        // Random pop to fill in the blanks
        for (int i = _init_pop.size(); i < _init_size; ++i) {
            _init_pop.emplace_back(std::make_shared<Phen>(this->_evo_params));
            _init_pop.back()->random(0, i);
        }

        this->_eval_pop(_init_pop);

        _add_to_container(_init_pop, _added);
        _container.get_full_content(this->_pop);
    }

    // Main Iteration of the QD algorithm
    void epoch() {
        // Selection of the parents (will fill the _parents vector)
        _selector(_parents, this->_pop);

        // Generation of the offspring
        // Note: there may be invalid ones generated after cross & mutation
        // TODO: also mutate the length of the gene?
        const auto& ids = misc::randomized_indices(_parents.size());
        for (size_t i = 0; i < _parents.size(); i += 2) {
            std::shared_ptr<Phen> i1, i2;
            _parents[ids[i]]->cross(_parents[ids[i + 1]], i1, i2);
            i1->set_id(this->_gen + 1, i);
            i2->set_id(this->_gen + 1, i + 1);
            i1->mutate();
            i2->mutate();
            _offspring[i] = i1;
            _offspring[i + 1] = i2;
        }

        // Evaluation of the offspring
        this->_eval_pop(_offspring);
        // Addition of the offspring to the container
        _add_to_container(_offspring, _added, _parents);
        // Copy of the containt of the container into the _pop object.
        _container.get_full_content(this->_pop);
    }

  protected:
    // Add the offspring into the container and update the score of the individuals from the
    // container and both of the sub population (offspring and parents)
    void _add_to_container(pop_t& pop_off, std::vector<bool>& added, pop_t& pop_parents)
    {
        // _container.reset_stat();
        added.resize(pop_off.size());
        for (size_t i = 0; i < pop_off.size(); ++i) {
            // TODO JBM: curiosity is hardcoded here...
            if (_container.add(pop_off[i])) {
                pop_parents[i]->fit().curiosity = pop_parents[i]->fit().curiosity + 1;
                added[i] = true;
            } else {
                pop_parents[i]->fit().curiosity = pop_parents[i]->fit().curiosity - 0.5;
                added[i] = false;
            }
        }
        _container.update(pop_off, pop_parents);
    }

    // Same function, but without the need of parent.
    void _add_to_container(pop_t& pop_off, std::vector<bool>& added)
    {
        // _container.reset_stat();
        added.resize(pop_off.size());
        for (size_t i = 0; i < pop_off.size(); ++i)
            added[i] = _container.add(pop_off[i]);
        pop_t empty;
        _container.update(pop_off, empty);
    }

    void _dump_config_extra() const {
        _sim_params.Save(this->_res_dir + "/sim_params.xml");
    }

    void _load_config_extra(const std::string& evo_params_fname) {
        std::filesystem::path res_path(evo_params_fname);
        _sim_params.Load(res_path.parent_path().string() + "/sim_params.xml");
        // TODO: the following load should be handled from outside -- probably in evo_main
        _sim_params.env_dir = this->_res_dir;
        _sim_params.parts_dir = this->_res_dir + "/robot_parts";
        this->_eval.init(_evo_params, _sim_params);
    }

    bool _load_state_extra(boost::archive::binary_iarchive& ia) {
        for (size_t i = 0; i < this->_pop.size(); ++i) {
            this->_pop[i]->set_params(this->_evo_params);
            this->_pop[i]->develop();
        }
        _add_to_container(this->_pop, _added);
        return true;
    }

    void _populate_params_extra() {
        _init_size = this->_evo_params.init_size();
        _pop_size = this->_evo_params.pop_size();
        _container.set_params(this->_evo_params);

        // reserve space for containers
        size_t map_capacity = 1;
        for (auto& dim : this->_evo_params.grid_shape())
            map_capacity *= dim;
        this->_pop.reserve(map_capacity);
        _parents.resize(_pop_size);
        _offspring.resize(_pop_size);
    }

    std::shared_ptr<std::vector<std::vector<double>>> _init_seeds;
    SimulatorParams _sim_params;
    size_t _init_size;
    size_t _pop_size;

    Selector _selector;
    Container _container;
    eval_t _eval;

    pop_t _init_pop;
    pop_t _parents;
    pop_t _offspring;
    std::vector<bool> _added;
};

} // namespace qd
} // namespace sferes

#endif /* end of include guard: EVOGEN_GENERATOR_SFERES_QD_EVOGENQD_HPP_ */
