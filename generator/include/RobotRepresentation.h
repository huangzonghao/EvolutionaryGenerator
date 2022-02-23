#ifndef EVOGEN_GENERATOR_ROBOTREPRESENTATION_H_
#define EVOGEN_GENERATOR_ROBOTREPRESENTATION_H_

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
        // position: [0, 0.5] - FL->BL, [0.5, 1] - BR->FR
        double position = 0;
        // double pos_x = 0;
        // double pos_y = 0;
        std::vector<Link> links = std::vector<Link>(1);

        Leg() {}
        Leg(int myid, int total_legs);

        void update_pos(int myid, int total_legs, int alt = 0);
        double length() const;
        bool operator<(const Leg& other) const;

        static double get_pos(int myid, int total_legs, int alt = 0) {
            // the position here determines which controller each leg gets
            const double preset_legpos2[2] = {0.25, 0.75};
            const double preset_legpos3[3] = {0.01, 0.75, 0.49};
            const double preset_legpos3_alt[3] = {0.51, 0.25, 0.99};
            const double preset_legpos4[4] = {0.01, 0.49, 0.51, 0.99};
            const double preset_legpos5[5] = {0.01, 0.49, 0.51, 0.99, 0.25};
            const double preset_legpos5_alt[5] = {0.99, 0.51, 0.49, 0.01, 0.75};
            const double preset_legpos6[6] = {0.01, 0.25, 0.49, 0.51, 0.75, 0.99};
            switch (total_legs) {
            case 2:
                return preset_legpos2[myid];
            case 3:
                if (alt == 0)
                    return preset_legpos3[myid];
                else
                    return preset_legpos3_alt[myid];
            case 4:
                return preset_legpos4[myid];
            case 5:
                if (alt == 0)
                    return preset_legpos5[myid];
                else
                    return preset_legpos5_alt[myid];
            case 6:
                return preset_legpos6[myid];
            default:
                std::cerr << "RobotRepresentation::Leg::get_pos: Wrong number of total legs " << total_legs << std::endl;
                exit(1);
            }
        }
    };

    RobotRepresentation();

    // the leg order: FL ML BL BR MR FR
    std::string robot_name = "temp_robot";
    std::string type = "mesh";
    std::vector<Leg> legs;
    int body_part_id = 0;
    double body_part_gene = 0;
    double body_scales[3] = {1, 1, 1};

    // dv format: [body_id, body_x, body_y, body_z, num_legs, leg_1, leg_2, ...]
    //     for each leg: [leg_pos, num_links, link_1_id, link_1_scale]
    int get_body_part_id() const;
    int get_link_part_id(int leg_id, int link_id) const;
    double get_body_size(int dir) const;
    double get_body_length() const;
    int num_legs() const;
    void update_num_legs(int new_num_legs, int alt); // alt: represent the alternative leg layout of asymmetrical robot
    std::string get_urdf_string() const;
    void export_urdf_file(const std::string& output_path) const;
    double get_leg_pos(int leg_id) const;
    friend std::ostream& operator<<(std::ostream& os, const RobotRepresentation& robot);
  private:
    std::string get_urdf_string_mesh() const;
    std::string get_urdf_string_primitive() const;
    bool collision_use_mesh_ = false;
    int num_legs_ = 0;
    double scale_min_ = 0;
    double scale_max_ = 1;
    double density_ = 2500; // unit: kg/m3. or x/1000 g/cm3
};

#endif /* end of include guard: EVOGEN_GENERATOR_ROBOTREPRESENTATION_H_ */
