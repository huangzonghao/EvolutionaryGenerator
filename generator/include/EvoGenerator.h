#ifndef EVOGENERATOR_H_MSPHUOQV
#define EVOGENERATOR_H_MSPHUOQV

#include <sferes/gen/evo_float.hpp>
#include <sferes/modif/dummy.hpp>
#include "sferes_fit_EvoGenFitness.hpp"
#include "sferes_phen_EvoGenPhen.hpp"
#include "sferes_eval_EvoGenEval.hpp"
#include "sferes_stat_EvoGenStat.hpp"
#include "sferes_qd_container_grid.hpp"
#include "sferes_qd_selector_uniform.hpp"
#include "sferes_qd_EvoGenQD.hpp"
#include "sferes_params.h"

typedef sferes::phen::EvoGenPhen<sferes::gen::EvoFloat<Params::evo_float::dimension, Params>,
                                 sferes::fit::EvoGenFitness<Params>,
                                 Params> phen_t;

typedef sferes::qd::EvoGenQD<phen_t,
                             sferes::eval::EvoGenEval<Params>,
                             boost::fusion::vector<sferes::stat::EvoGenStat<phen_t, Params> >,
                             sferes::modif::Dummy<> modifier_t,
                             sferes::qd::selector::Uniform<phen_t>,
                             sferes::qd::container::Grid<phen_t> > EvoGenerator;


#endif /* end of include guard: EVOGENERATOR_H_MSPHUOQV */
