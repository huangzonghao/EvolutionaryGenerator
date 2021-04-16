// Evaluator for sferes2
#ifndef SFERES_EVAL_EVOGENEVAL_HPP_LJHETCPM
#define SFERES_EVAL_EVOGENEVAL_HPP_LJHETCPM
#include <vector>
#include <boost/shared_ptr.hpp>
#include <sferes/dbg/dbg.hpp>
#include <sferes/stc.hpp>

#include "SimulationManager.h"

namespace sferes {
namespace eval {

SFERES_CLASS(EvoGenEval) {
  public:
    EvoGenEval() : _nb_evals(0) {}
    template<typename Phen>
    void eval(std::vector<boost::shared_ptr<Phen> >& pop, size_t begin, size_t end,
                const typename Phen::fit_t& fit_proto) {
        dbg::trace trace("eval", DBG_HERE);
        assert(pop.size());
        assert(begin < pop.size());
        assert(end <= pop.size());

        SimulationManager sm;
        sm.SetTimeout(10);
        sm.SetCamera(2.5, -1, 3, 2.5, 1.5, 0);
        sm.AddWaypoint(0.5, 1.5, 0.3);

        sm.SetEnv("ground", 5, 3, 0.01);
        // sm.SetEnv(Resource_Map_Dir + "/env3.bmp", 5, 3, 0.3);

        sm.AddMotor("MOTOR", "chassis", "chassis_wheel_fl", 1,0.1,0.1,0.1);
        sm.AddMotor("MOTOR", "chassis", "chassis_wheel_rl", 1,0.1,0.1,0.1);
        sm.AddMotor("MOTOR", "chassis", "chassis_wheel_fr", 1,0.1,0.1,0.1);
        sm.AddMotor("MOTOR", "chassis", "chassis_wheel_rr", 1,0.1,0.1,0.1);

        // sm.SetVisualization(false);
        // sm.SetRealTime();

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
};

} // namespace eval
} // namespace sferes

#endif /* end of include guard: SFERES_EVAL_EVOGENEVAL_HPP_LJHETCPM */
