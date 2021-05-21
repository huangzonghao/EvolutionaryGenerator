// Evaluator for sferes2
#ifndef SFERES_EVAL_EVOGENEVAL_HPP_LJHETCPM
#define SFERES_EVAL_EVOGENEVAL_HPP_LJHETCPM
#include <thread>
#include <vector>

#include "SimulationManager.h"
#include "SimulatorParams.h"

namespace sferes {
namespace eval {

class EvoGenEval {
  public:
    // this constructor is directly called in ea.hpp when initiating the
    // instance, and would not take any input
    EvoGenEval() : _nb_evals(0) {}

    void set_sim_params(const SimulatorParams& sim_params) {
        if (sim_params.do_viz)
            num_threads = 1;
        else
            num_threads = std::thread::hardware_concurrency();
        threads.resize(num_threads);

        sms.clear();
        for (int i = 0; i < num_threads; ++i) {
            auto& sm = std::make_shared<SimulationManager>();

            sm->SetTimeout(sim_params.time_out);
            sm->SetCamera(sim_params.camera_pos[0],
                          sim_params.camera_pos[1],
                          sim_params.camera_pos[2],
                          sim_params.camera_pos[3],
                          sim_params.camera_pos[4],
                          sim_params.camera_pos[5]);
            for (auto& wp : sim_params.GetWaypoints())
                sm->AddWaypoint(wp[0], wp[1], wp[2]);

            sm->SetEnv(sim_params.env_name,
                       sim_params.env_dim[0],
                       sim_params.env_dim[1],
                       sim_params.env_dim[2]);
            sm->SetEnvRot(sim_params.env_rot[0],
                          sim_params.env_rot[1],
                          sim_params.env_rot[2],
                          sim_params.env_rot[3]);

            sm->SetVisualization(sim_params.do_viz);
            sm->SetRealTime(sim_params.do_realtime);

            sms.push_back(sm);
        }
    }

    template<typename Phen>
    void eval_kernel(const std::vector<std::shared_ptr<Phen> >& pop,
                     const std::shared_ptr<SimulationManager>& sm,
                     size_t start_idx, size_t end_idx)
    {
        for (size_t i = start_idx; i < end_idx; ++i) {
            pop[i]->develop();
            pop[i]->fit().eval(*pop[i], *sm);
        }
    }

    template<typename Phen>
    void eval(std::vector<std::shared_ptr<Phen> >& pop, size_t begin, size_t end)
    {
        assert(pop.size());
        assert(begin < pop.size());
        assert(end <= pop.size());

        size_t batch_size = pop.size() / num_threads;
        size_t num_leftovers = pop.size() % num_threads;
        size_t element_cursor = 0;
        for (int i = 0; i < num_leftovers; ++i) {
            threads[i] = std::make_shared<std::thread>(&EvoGenEval::eval_kernel<Phen>, this, pop, sms[i],
                                                       element_cursor, element_cursor + batch_size + 1);
            element_cursor += batch_size + 1;
        }
        for (int i = num_leftovers; i < num_threads; ++i) {
            threads[i] = std::make_shared<std::thread>(&EvoGenEval::eval_kernel<Phen>, this, pop, sms[i],
                                                       element_cursor, element_cursor + batch_size);
            element_cursor += batch_size;
        }

        for (auto& thread : threads)
            thread->join();

        for (auto& thread : threads)
            thread.reset();
        _nb_evals += end - begin;
    }

    size_t nb_evals() const { return _nb_evals; }

  protected:
    size_t _nb_evals; // for stat to book the total number of phen that has been evaluated
    std::vector<std::shared_ptr<SimulationManager> > sms;
    size_t num_threads;
    std::vector<std::shared_ptr<std::thread> > threads;
};

} // namespace eval
} // namespace sferes

#endif /* end of include guard: SFERES_EVAL_EVOGENEVAL_HPP_LJHETCPM */
