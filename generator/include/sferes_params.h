#ifndef SFERES_PARAMS_H_VEZVLL4C
#define SFERES_PARAMS_H_VEZVLL4C

#include <sferes/stc.hpp>
#include <sferes/gen/evo_float.hpp>

struct Params {
    struct evo_float {
        // dimension of the genotype
        SFERES_CONST size_t dimension = 7;

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

    struct pop {
        // number of initial random points
        SFERES_CONST size_t init_size = 30;
        // number of initial seeds = initial_aleat * size
        SFERES_CONST size_t initial_aleat = 1;
        SFERES_CONST size_t size = 30;
        SFERES_CONST size_t nb_gen = 30;
        // number of generations to take archive
        SFERES_CONST size_t dump_period = -1; // disable default archive
        SFERES_CONST size_t evogen_dump_period = 1;
        SFERES_CONST bool dump_all_robots = true;
    };

    struct parameters {
        SFERES_CONST float min = 0.5;
        SFERES_CONST float max = 1.5;
    };

    struct nov {
        SFERES_CONST size_t deep = 2;
        SFERES_CONST double l = 1;
        SFERES_CONST double k = 8;
        SFERES_CONST double eps = 0.01;
    };

    struct qd {
        SFERES_CONST size_t behav_dim = 2;
        SFERES_ARRAY(size_t, grid_shape, 20, 20);
    };
};


#endif /* end of include guard: SFERES_PARAMS_H_VEZVLL4C */
