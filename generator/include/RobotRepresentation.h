#ifndef EVOGEN_GENERATOR_INCLUDE_ROBOTREPRESENTATION_H_
#define EVOGEN_GENERATOR_INCLUDE_ROBOTREPRESENTATION_H_

#include <iostream>
#include <vector>

class RobotRepresentation {
  public:
    struct Link {
        int part_id = 0;
        double part_gene = 0;
        double scale = 1;
        // double pos_z = 0;
    };

    class Leg {
      public:
        int num_links = 1;
        double position = 0;
        // double pos_x = 0;
        // double pos_y = 0;
        std::vector<Link> links = std::vector<Link>(1);

        Leg() {}
        Leg(int myid, int total_legs);

        void update_pos(int myid, int total_legs);
        static double RobotRepresentation::Leg::get_pos(int myid, int total_legs) {
            const double preset_legpos4[4] = {0.01, 0.99, 0.49, 0.51};
            const double preset_legpos6[6] = {0.01, 0.99, 0.49, 0.51, 0.25, 0.75};
            switch (total_legs) {
            case 4:
                return preset_legpos4[myid];
            case 6:
                return preset_legpos6[myid];
            default:
                std::cerr << "RobotRepresentation::Leg::get_pos: Wrong number of total legs " << total_legs << std::endl;
                exit(1);
            }
        }
    };

    int num_legs = 4;
    // the leg order: FL FR ML MR BL BR
    std::vector<Leg> legs = std::vector<Leg>(4);
    int body_part_id = 0;
    double body_part_gene = 0;
    double body_scales[3] = {1, 1, 1};

    std::vector<double> design_vector;

    RobotRepresentation();
    RobotRepresentation(std::vector<double> new_dv);

    // dv format: [body_id, body_x, body_y, body_z, num_legs, leg_1, leg_2, ...]
    //     for each leg: [leg_pos, num_links, link_1_id, link_1_scale]
    void encode_design_vector();
    void decode_design_vector();
    void decode_design_vector(const std::vector<double>& new_dv);
    int get_body_part_id() const;
    int get_link_part_id(int leg_id, int link_id) const;
    double get_body_length();
};

std::ostream& operator<<(std::ostream& os, const RobotRepresentation& robot);

#endif /* end of include guard: EVOGEN_GENERATOR_INCLUDE_ROBOTREPRESENTATION_H_ */
