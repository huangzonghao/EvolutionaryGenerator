// Evaluator for sferes2
#ifndef EVOGEN_GENERATOR_SFERES_EVAL_EVOGENEVAL_HPP_
#define EVOGEN_GENERATOR_SFERES_EVAL_EVOGENEVAL_HPP_

#include <thread>
#include <vector>

#include "MeshInfo.h"
#include "SimulationManager.h"
#include "SimulatorParams.h"

extern MeshInfo mesh_info;

namespace sferes {
namespace eval {

class EvoGenEval {
  public:
    void set_sim_params(const SimulatorParams& sim_params) {
        if (sim_params.do_viz)
            num_threads = 1;
        else
            num_threads = std::thread::hardware_concurrency();
        threads.resize(num_threads);

        sms.clear();
        for (int i = 0; i < num_threads; ++i) {
            const auto& sm = std::make_shared<SimulationManager>();

            sm->SetTimeout(sim_params.time_out);
            sm->SetCamera(sim_params.camera_pos[0],
                          sim_params.camera_pos[1],
                          sim_params.camera_pos[2],
                          sim_params.camera_pos[3],
                          sim_params.camera_pos[4],
                          sim_params.camera_pos[5]);
            for (auto& wp : sim_params.GetWaypoints())
                sm->AddWaypoint(wp[0], wp[1], wp[2]);

            sm->SetEnv(sim_params.GetEnv(),
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

        mesh_info.set_mesh_dir(sim_params.parts_dir);
        mesh_info.init();
    }

    template<typename Phen>
    void eval_kernel(const std::vector<std::shared_ptr<Phen>>& pop,
                     const std::shared_ptr<SimulationManager>& sm,
                     size_t start_idx, size_t end_idx)
    {
        for (size_t i = start_idx; i < end_idx; ++i) {
            if (pop[i]->develop())
                ++num_valid;
            pop[i]->fit().eval(*pop[i], *sm);
        }
    }

    template<typename Phen>
    void eval(std::vector<std::shared_ptr<Phen>>& pop, size_t begin, size_t end) {
        assert(pop.size());
        assert(begin < pop.size());
        assert(end <= pop.size());

        num_valid = 0;
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
        std::cout << std::endl << "valid robots of this batch: " << num_valid << "/ " << pop.size() << std::endl;
    }

    size_t nb_evals() const { return _nb_evals; }

  protected:
    size_t _nb_evals = 0; // for stat to book the total number of phen that has been evaluated
    std::vector<std::shared_ptr<SimulationManager>> sms;
    size_t num_threads;
    std::vector<std::shared_ptr<std::thread>> threads;
    static int num_valid;
};

int EvoGenEval::num_valid = 0;

} // namespace eval
} // namespace sferes

#endif /* end of include guard: EVOGEN_GENERATOR_SFERES_EVAL_EVOGENEVAL_HPP_ */
