#ifndef SFERES_PARAMS_H_VEZVLL4C
#define SFERES_PARAMS_H_VEZVLL4C

#include <fstream>
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

    static void Save(const std::string& filename) {
        // // output sferes params
        // std::ofstream ofs(filename);
        // ofs << pop::nb_gen << "," // 0
            // << pop::init_size << "," // 1
            // << pop::size << "," // 2
            // << pop::text_archive_dump_period << "," // 3
            // << qd::behav_dim << "," // 4
            // << qd::grid_shape(0) << "," // 5
            // << qd::grid_shape(1); // 6
        // ofs.close();
    }

};


#endif /* end of include guard: SFERES_PARAMS_H_VEZVLL4C */
