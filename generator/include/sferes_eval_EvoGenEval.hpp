// Evaluator for sferes2
#ifndef SFERES_EVAL_EVOGENEVAL_HPP_LJHETCPM
#define SFERES_EVAL_EVOGENEVAL_HPP_LJHETCPM
#include <vector>
#include <boost/shared_ptr.hpp>
#include <sferes/dbg/dbg.hpp>
#include <sferes/stc.hpp>

#include "SimulationManager.h"
#include "SimulatorParams.h"

namespace sferes {
namespace eval {

SFERES_CLASS(EvoGenEval) {
  public:
    EvoGenEval() : _nb_evals(0) {
        // this constructor is directly called in ea.hpp when initiating the
        // instance, and would not take any input

        sm.SetTimeout(sim_params.time_out);
        sm.SetCamera(sim_params.camera_pos[0],
                     sim_params.camera_pos[1],
                     sim_params.camera_pos[2],
                     sim_params.camera_pos[3],
                     sim_params.camera_pos[4],
                     sim_params.camera_pos[5]);
        for (auto& wp : sim_params.GetWaypoints())
            sm.AddWaypoint(wp[0], wp[1], wp[2]);

        sm.SetEnv(sim_params.env_name,
                  sim_params.env_dim[0],
                  sim_params.env_dim[1],
                  sim_params.env_dim[2]);

        sm.AddMotor("MOTOR", "chassis", "chassis_wheel_fl", 1,0.1,0.1,0.1);
        sm.AddMotor("MOTOR", "chassis", "chassis_wheel_rl", 1,0.1,0.1,0.1);
        sm.AddMotor("MOTOR", "chassis", "chassis_wheel_fr", 1,0.1,0.1,0.1);
        sm.AddMotor("MOTOR", "chassis", "chassis_wheel_rr", 1,0.1,0.1,0.1);

        sm.SetVisualization(sim_params.do_viz);
        sm.SetRealTime(sim_params.do_realtime);
    }
    template<typename Phen>
    void eval(std::vector<boost::shared_ptr<Phen> >& pop, size_t begin, size_t end,
                const typename Phen::fit_t& fit_proto) {
        dbg::trace trace("eval", DBG_HERE);
        assert(pop.size());
        assert(begin < pop.size());
        assert(end <= pop.size());

        for (size_t i = begin; i < end; ++i) {
            pop[i]->fit() = fit_proto;
            pop[i]->develop();
            pop[i]->fit().eval(*pop[i], sm);
            _nb_evals++;
        }
    }
    unsigned nb_evals() const { return _nb_evals; }
  protected:
    unsigned _nb_evals;
    SimulationManager sm;
};

} // namespace eval
} // namespace sferes

#endif /* end of include guard: SFERES_EVAL_EVOGENEVAL_HPP_LJHETCPM */
