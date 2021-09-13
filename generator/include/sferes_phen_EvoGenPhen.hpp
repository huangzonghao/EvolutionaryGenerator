#ifndef EVOGEN_GENERATOR_SFERES_PHEN_EVOGENPHEN_HPP_
#define EVOGEN_GENERATOR_SFERES_PHEN_EVOGENPHEN_HPP_

#include <vector>
#include <iostream>
#include <boost/serialization/nvp.hpp>

#include "RobotRepresentation.h"
#include "MeshInfo.h"
#include "EvoParams.h"

extern MeshInfo mesh_info; // defined in MeshInfo.cpp

namespace sferes {
namespace phen {

// phen related values
static const int robot_meta_size = 2; // num_legs, side of extra leg for 3/5-leg robot
static const int body_meta_size = 4; // body_id, body_x, body_y, body_z
static const int leg_meta_size = 2; // leg_pos, num_links
static const int link_meta_size = 2; // link_id, link_scale

// controller related values
static const int max_num_legs = 6;
static const int min_num_legs = 2;
static const int max_num_links = 3;
static const int min_num_links = 2;

// derived values
static const int gen_max_length = robot_meta_size + body_meta_size + max_num_legs * (leg_meta_size + max_num_links * link_meta_size);

template <typename Gen, typename Fit>
class EvoGenPhen {
  public:
    typedef Fit fit_t;
    typedef Gen gen_t;

    template<typename G, typename F>
    friend std::ostream& operator<<(std::ostream& output, const EvoGenPhen<G, F>& e);

    // scale up a value in [0, 1] to [min, max]
    inline double gene_to_range(double raw, double min, double max) {
        assert(raw >= 0); assert(raw <= 1); assert(min <= max);
        return raw * (max - min) + min;
    }

    // convert a gene in [0, 1) to integers of {0, 1, ..., count - 1}
    inline int gene_to_id(double raw, int count) {
        assert(count > 0); assert(raw >= 0); assert(raw <= 1);
        int ret = std::floor(raw * count);
        ret = std::min(ret, count - 1); // ret == count when raw == 1
        return ret;
    }

    // convert a gene in [0, 1) to integers of {min, min + 1, ... , max - 1, max}
    inline int gene_to_id(double raw, int min, int max) {
        assert(min <= max);
        return gene_to_id(raw, max - min + 1) + min;
    }

    EvoGenPhen() {}
    EvoGenPhen(const std::vector<double>& gene, double min_p, double max_p)
        : _gen(gene), _min_p(min_p), _max_p(max_p) {}
    EvoGenPhen(double min_p, double max_p) : _min_p(min_p), _max_p(max_p) {}
    EvoGenPhen(const EvoParams& evo_params) { set_params(evo_params); }
    EvoGenPhen(const std::vector<double>& gene, const EvoParams& evo_params)
        : _gen(gene) { set_params(evo_params); }

    bool valid() { return _valid; }
    Fit& fit() { return _fit; }
    const Fit& fit() const { return _fit; }

    Gen& gen()  { return _gen; }
    const Gen& gen() const { return _gen; }
    void mutate() { _gen.mutate(); }
    // actually the random inits are guaranteed to be valid
    void random() { _gen.random(); }

    void cross(const std::shared_ptr<EvoGenPhen> i2,
               std::shared_ptr<EvoGenPhen>& o1,
               std::shared_ptr<EvoGenPhen>& o2) {
        if (!o1)
            o1 = std::make_shared<EvoGenPhen>(_min_p, _max_p);
        if (!o2)
            o2 = std::make_shared<EvoGenPhen>(_min_p, _max_p);
        _gen.cross(i2->gen(), o1->gen(), o2->gen());
    }

    // Genome to Robot Conversion & Verification
    // gen format: [body_id, body_x, body_y, body_z, num_legs, alt, leg_1, leg_2, ...]
    //     for each leg: [(leg_pos), num_links, link_1_id, link_1_scale]
    // Leg order: FL ML BL BR MR FR
    // Note: develop is usually called right before fitness eval
    bool develop() {
        // Fill in the robot representation here and determin if the gene gives a valid robot
        // The invalid robot occurs when there are not enough elements in gene to
        // describe the required number of legs & links
        // NOTE: any change here means changing the definition of genome
        int cursor = 0;
        try {
            const auto& gene = _gen.data();
            _robot.body_part_gene = gene.at(cursor++);
            _robot.body_part_id = gene_to_id(_robot.body_part_gene, mesh_info.num_bodies());
            for (int i = 0; i < 3; ++i)
                _robot.body_scales[i] = gene_to_range(gene.at(cursor++), _min_p, _max_p);
            int num_legs = gene_to_id(gene.at(cursor++), min_num_legs, max_num_legs);
            double alt_gene = gene.at(cursor++); // this is a dumb gene for symmetrical robot
            _robot.update_num_legs(num_legs, alt_gene > 0.5 ? 1 : 0);
            for (int i = 0; i < num_legs; ++i) {
                auto& tmp_leg = _robot.legs[i];
                // tmp_leg.position = gene.at(cursor++);
                tmp_leg.num_links = gene_to_id(gene.at(cursor++), min_num_links, max_num_links);
                tmp_leg.links.resize(tmp_leg.num_links);
                for(int j = 0; j < tmp_leg.num_links; ++j) {
                    auto& tmp_link = tmp_leg.links[j];
                    tmp_link.part_gene = gene.at(cursor++);
                    tmp_link.scale = gene_to_range(gene.at(cursor++), _min_p, _max_p);
                    tmp_link.part_id = gene_to_id(tmp_link.part_gene, mesh_info.num_legs());
                }
            }
        } catch (const std::out_of_range& oor) {
            _valid = false;
            return false;
        }

        // Sort legs based on their position
        // Note this information doesn't need to send back to gene, as it's
        // purely for the conveninece of the controller
        std::sort(_robot.legs.begin(), _robot.legs.end());

        // Trim the unnecessary elements in gene
        _gen.resize(cursor);
        _valid = true;
        return true;
    }

    double data(size_t i) const {
        assert(i < size());
        return _gen.data(i);
    }

    size_t size() const { return _gen.size(); }
    const std::vector<double>& data() const { return _gen.data(); }

    // squared Euclidean distance
    double dist(const EvoGenPhen& params) const {
        assert(params.size() == size());
        double d = 0.0f;
        for (size_t i = 0; i < _gen.size(); ++i) {
            double x = this->data(i) - params.data(i);
            d += x * x;
        }
        return d;
    }

    void show(std::ostream& os) const {
        for (auto p : _gen.data())
            os << p << " " << std::endl;
    }

    void set_params(const EvoParams& evo_params) {
        _max_p = evo_params.phen_data_max();
        _min_p = evo_params.phen_data_min();
    }

    const RobotRepresentation& get_robot() { return _robot; }

    template<class Archive>
    void serialize(Archive & ar, const unsigned int version) {
        ar & BOOST_SERIALIZATION_NVP(_gen);
        ar & BOOST_SERIALIZATION_NVP(_fit);
    }

  protected:
    Gen _gen;
    Fit _fit;
    double _min_p;
    double _max_p;
    bool _valid = false;
    const double pos[3] = {0.01, 0.25, 0.49};
    RobotRepresentation _robot;
};

template<typename G, typename F>
std::ostream& operator<<(std::ostream& output, const EvoGenPhen<G, F>& e) {
    output << _robot;
    return output;
}

} // namespace phen
} // namespace sferes

#endif /* end of include guard: EVOGEN_GENERATOR_SFERES_PHEN_EVOGENPHEN_HPP_ */
