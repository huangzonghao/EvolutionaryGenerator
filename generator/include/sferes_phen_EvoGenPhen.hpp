#ifndef EVOGEN_GENERATOR_SFERES_PHEN_EVOGENPHEN_HPP_
#define EVOGEN_GENERATOR_SFERES_PHEN_EVOGENPHEN_HPP_

#include <vector>
#include <iostream>
#include <boost/serialization/nvp.hpp>

#include "sferes_gen_EvoGenFloat.hpp"
// #include "sferes_fit_RobogamiFitness.hpp"
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

struct PhenID {
    int gen = 0;
    int id = 0;
    int p1_gen = -1; // -1 means no parent
    int p1_id = -1;
    int p2_gen = -1;
    int p2_id = -1;

    void set(int new_gen = 0, int new_id = 0) {
        gen = new_gen;
        id = new_id;
    }

    void set_parent(const PhenID& p1, const PhenID& p2) {
        p1_gen = p1.gen;
        p1_id = p1.id;
        p2_gen = p2.gen;
        p2_id = p2.id;
    }

    void set_parent(int new_p1_gen = -1, int new_p1_id = -1,
                    int new_p2_gen = -1, int new_p2_id = -1) {
        p1_gen = new_p1_gen;
        p1_id = new_p1_id;
        p2_gen = new_p2_gen;
        p2_id = new_p2_id;
    }

    template<class Archive>
    void serialize(Archive & ar, const unsigned int version) {
        ar & BOOST_SERIALIZATION_NVP(gen);
        ar & BOOST_SERIALIZATION_NVP(id);
        ar & BOOST_SERIALIZATION_NVP(p1_gen);
        ar & BOOST_SERIALIZATION_NVP(p1_id);
        ar & BOOST_SERIALIZATION_NVP(p2_gen);
        ar & BOOST_SERIALIZATION_NVP(p2_id);
    }
};

class PhenFitness {
  public:
    // Set flag in descriptors.
    void write_desc(double value) {
        for (int i = 0; i < desc.size(); ++i)
            desc[i] = value;
    }
    void clamp_desc() {
        for (auto& e : desc)
            e = std::clamp(e, 0.0, 1.0);
    }

    template<class Archive>
    void serialize(Archive & ar, const unsigned int version) {
        ar & BOOST_SERIALIZATION_NVP(value);
        ar & BOOST_SERIALIZATION_NVP(desc);
    }

    // A robot is dead if:
    //     * Gene is invalid (too short)
    //     * Self-collided at initial pose
    bool dead = false;
    // std::vector<double> _desc = {-1.0, -1.0, -1.0, -1.0};
    std::vector<double> desc = {-1.0, -1.0};
    double novelty = -std::numeric_limits<double>::infinity();
    double curiosity = 0;
    double local_quality = 0;
    double value = 0;
};

// TODO: EvoGenPhen::_valid and PhenFitness::_dead is duplicated
class EvoGenPhen {
  public:
    // TODO: hard coded grid dimension
    typedef PhenFitness fit_t;
    // typedef sferes::fit::RobogamiFitness fit_t;
    typedef sferes::gen::EvoGenFloat gen_t;
    typedef PhenID phen_id_t;

    friend std::ostream& operator<<(std::ostream& output, const EvoGenPhen& e);

    int grid_dim = 2;

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
    EvoGenPhen(const std::vector<double>& gene, double min_p, double max_p, int dim)
        : _gene(gene) { set_params(min_p, max_p, dim); }
    EvoGenPhen(double min_p, double max_p, int dim) { set_params(min_p, max_p, dim); }
    EvoGenPhen(const EvoParams& evo_params) { set_params(evo_params); }
    EvoGenPhen(const std::vector<double>& gene, const EvoParams& evo_params)
        : _gene(gene) { set_params(evo_params); }

    void set_id(int gen_id = 0, int id = 0) { _id.set(gen_id, id); }
    void set_parent(const EvoGenPhen& p1, const EvoGenPhen& p2) { _id.set_parent(p1.id(), p2.id()); }
    void set_parent(const PhenID& p1, const PhenID& p2) { _id.set_parent(p1, p2); }
    void set_parent(int p1_gen_id = -1, int p1_id = -1, int p2_gen_id = -1, int p2_id = -1) {
        _id.set_parent(p1_gen_id, p1_id, p2_gen_id, p2_id);
    }

    PhenID& id() { return _id; }
    const PhenID& id() const { return _id; }

    bool valid() { return _valid; }
    fit_t& fit() { return _fit; }
    const fit_t& fit() const { return _fit; }

    void set_grid_id(const std::vector<int> new_id) {
        if (new_id.size() != _grid_id.size()) {
            std::cout << "Error: grid id dimension doesn't match, phen grid id dim: "
                      << _grid_id.size() << ", passed in grid id dim: " << new_id.size()
                      << std::endl;
        }
        _grid_id = new_id;
    }
    const std::vector<int>& grid_id() { return _grid_id; }

    gen_t& gen()  { return _gene; }
    const gen_t& gen() const { return _gene; }
    const RobotRepresentation& robot() const { return _robot; }

    void mutate() { _gene.mutate(); }
    // actually the random inits are guaranteed to be valid
    void random(int gen_id = 0, int id = 0) {
        _id.set(gen_id, id);
        _id.set_parent(-1, -1, -1, -1); // no parent for random seeds -- note phen generated by random doesn't necessarily be gen 0
        _gene.random();
    }

    void cross(const std::shared_ptr<EvoGenPhen> i2,
               std::shared_ptr<EvoGenPhen>& o1,
               std::shared_ptr<EvoGenPhen>& o2) {
        if (!o1) {
            // TODO: should probably use a copy constructor here
            o1 = std::make_shared<EvoGenPhen>(_min_p, _max_p, grid_dim);
            o1->set_parent(_id, i2->id());
        }
        if (!o2) {
            o2 = std::make_shared<EvoGenPhen>(_min_p, _max_p, grid_dim);
            o2->set_parent(_id, i2->id());
        }
        _gene.cross(i2->gen(), o1->gen(), o2->gen());
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
            const auto& gene = _gene.data();
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
        _gene.resize(cursor);
        _valid = true;
        return true;
    }

    double data(size_t i) const {
        assert(i < size());
        return _gene.data(i);
    }

    size_t size() const { return _gene.size(); }
    const std::vector<double>& data() const { return _gene.data(); }

    // squared Euclidean distance
    double dist(const EvoGenPhen& params) const {
        assert(params.size() == size());
        double d = 0.0f;
        for (size_t i = 0; i < _gene.size(); ++i) {
            double x = this->data(i) - params.data(i);
            d += x * x;
        }
        return d;
    }

    void show(std::ostream& os) const {
        for (auto p : _gene.data())
            os << p << " " << std::endl;
    }

    void set_params(double min_p, double max_p, int dim) {
        _min_p = min_p;
        _max_p = max_p;
        grid_dim = dim;
        _grid_id.resize(grid_dim);
        for (auto& id : _grid_id) id = -1;
        _fit.desc.resize(dim);
    }

    void set_params(const EvoParams& evo_params) {
        set_params(evo_params.phen_data_min(), evo_params.phen_data_max(), evo_params.grid_shape().size());
    }

    const RobotRepresentation& get_robot() { return _robot; }

    template<class Archive>
    void serialize(Archive & ar, const unsigned int version) {
        ar & BOOST_SERIALIZATION_NVP(_id);
        ar & BOOST_SERIALIZATION_NVP(_gene);
        ar & BOOST_SERIALIZATION_NVP(_fit);
        ar & BOOST_SERIALIZATION_NVP(_grid_id);
    }

  protected:
    gen_t _gene;
    fit_t _fit;
    PhenID _id;
    double _min_p;
    double _max_p;
    bool _valid = false;
    const double pos[3] = {0.01, 0.25, 0.49};
    std::vector<int> _grid_id; // initialize all values to -1.
    RobotRepresentation _robot;
};

std::ostream& operator<<(std::ostream& output, const EvoGenPhen& e) {
    output << e.robot();
    return output;
}

} // namespace phen
} // namespace sferes

#endif /* end of include guard: EVOGEN_GENERATOR_SFERES_PHEN_EVOGENPHEN_HPP_ */
