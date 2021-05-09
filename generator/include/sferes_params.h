#ifndef SFERES_PARAMS_H_VEZVLL4C
#define SFERES_PARAMS_H_VEZVLL4C

#include <fstream>
#include <sferes/stc.hpp>
#include <sferes/gen/evo_float.hpp>

struct Params {
    struct evo_float {
        // dimension of the genotype
        SFERES_CONST size_t dimension = 16;

        // Mutation
        // polynomial, gaussian, uniform
        SFERES_CONST sferes::gen::evo_float::mutation_t
            mutation_type = sferes::gen::evo_float::polynomial;
        SFERES_CONST float mutation_rate = 0.1f;
        SFERES_CONST float eta_m = 10.0f;

        // Crossover
        // sbx, recombination
        SFERES_CONST sferes::gen::evo_float::cross_over_t
            cross_over_type = sferes::gen::evo_float::sbx;
        SFERES_CONST float cross_rate = 0.75f;
        SFERES_CONST float eta_c = 10.0f;
    };

    struct qd {
        SFERES_CONST size_t behav_dim = 2;
    };
};


#endif /* end of include guard: SFERES_PARAMS_H_VEZVLL4C */
