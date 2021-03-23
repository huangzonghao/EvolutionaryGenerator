#include <iostream>

#include <sferes/eval/parallel.hpp>
#include <sferes/gen/evo_float.hpp>
#include <sferes/modif/dummy.hpp>
#include <sferes/phen/parameters.hpp>
#include <sferes/run.hpp>
#include <sferes/stat/best_fit.hpp>
#include <sferes/stat/qd_container.hpp>
#include <sferes/stat/qd_selection.hpp>
#include <sferes/stat/qd_progress.hpp>

#include <sferes/fit/fit_qd.hpp>
#include <sferes/qd/container/archive.hpp>
#include <sferes/qd/container/grid.hpp>
#include <sferes/qd/quality_diversity.hpp>
#include <sferes/qd/selector/uniform.hpp>

using namespace sferes::gen::evo_float;

# define M_PI           3.14159265358979323846  /* pi */

struct Params {
    struct nov {
        SFERES_CONST size_t deep = 2;
        SFERES_CONST double l = 1; // TODO value ???
        SFERES_CONST double k = 8; // TODO right value?
        SFERES_CONST double eps = 0.01;// TODO right value??
    };

    // TODO: move to a qd::
    struct pop {
        // number of initial random points
        SFERES_CONST size_t init_size = 10;
        // size of a batch
        SFERES_CONST size_t size = 10;
        SFERES_CONST size_t nb_gen = 2;
        SFERES_CONST size_t dump_period = 1;
    };
    struct parameters {
        SFERES_CONST float min = -5;
        SFERES_CONST float max = 5;
    };
    struct evo_float {
        SFERES_CONST float cross_rate = 0.75f;
        SFERES_CONST float mutation_rate = 0.1f;
        SFERES_CONST float eta_m = 10.0f;
        SFERES_CONST float eta_c = 10.0f;
        SFERES_CONST mutation_t mutation_type = polynomial;
        SFERES_CONST cross_over_t cross_over_type = sbx;
    };
    struct qd {
        SFERES_CONST size_t behav_dim = 1;
        SFERES_ARRAY(size_t, grid_shape, 4);
    };
};

// Rastrigin
FIT_QD(Rastrigin) {
public:
    template <typename Indiv>
    void eval(Indiv & ind) {
        float f = 10 * ind.size();
        std::cout << "Size: " << ind.size() << std::endl;
        std::cout << "Data: " << ind.data(0) << std::endl;
        for (size_t i = 0; i < ind.size(); ++i)
            f += ind.data(i) * ind.data(i) - 10 * cos(2 * M_PI * ind.data(i));

        if (this->mode() == sferes::fit::mode::view)
        {
            std::ofstream ofs("fit.dat");
            ofs << "this is a log file !" << std::endl;
        }

        this->_value = -f;

        std::vector<double> data = { ind.gen().data(0), ind.gen().data(1) };
        std::cout << ind.gen().data(0) << std::endl;
        std::cout << ind.gen().data(1) << std::endl;
        this->set_desc(data);
    }
};

int main(int argc, char **argv)
{
    using namespace sferes;

    typedef Rastrigin<Params> fit_t;
    typedef gen::EvoFloat<5, Params> gen_t;

    //std::cout << "Gen: " << gen_t.data << std::endl;
    typedef phen::Parameters<gen_t, fit_t, Params> phen_t;

    typedef eval::Parallel<Params> eval_t;

    typedef boost::fusion::vector<
        sferes::stat::BestFit<phen_t, Params>,
        sferes::stat::QdContainer<phen_t, Params>,
        sferes::stat::QdProgress<phen_t, Params>
    >
        stat_t;
    typedef modif::Dummy<> modifier_t;
    typedef qd::MapElites<phen_t, eval_t, stat_t, modifier_t, Params>
        qd_t;

    qd_t qd;
    run_ea(argc, argv, qd);
    //std::cout << "qd:" << qd. << std::endl;
    std::cout << "best fitness:" << qd.stat<0>().best()->fit().value() << std::endl;
    std::cout << "archive size:" << qd.stat<1>().archive().size() << std::endl;
    return 0;
}
