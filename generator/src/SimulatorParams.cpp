#include "SimulatorParams.h"

#include <fstream>

void SimulatorParams::AddWaypoint(double x, double y, double z) {
    waypoints_.push_back(std::vector<double>{x,y,z});
}

void SimulatorParams::SetCamera(double from_x, double from_y, double from_z,
                                double to_x, double to_y, double to_z) {
    camera_pos[0] = from_x;
    camera_pos[1] = from_y;
    camera_pos[2] = from_z;
    camera_pos[3] = to_x;
    camera_pos[4] = to_y;
    camera_pos[5] = to_z;
}

bool SimulatorParams::Save(std::string filename) {
    std::ofstream ofs;
    ofs.open(filename);
    if (!ofs) {
        std::cerr << "Error: Could not create file " << filename << std::endl;
        return false;
    }
    ofs << *this;
    ofs.close();
    return true;
}

bool SimulatorParams::Load(std::string filename) {
    std::ifstream ifs;
    ifs.open(filename);

    if (!ifs) {
        std::cerr << "Error: Could not open file " << filename << std::endl;
        return false;
    }

    ifs.ignore(20, ' ');
    ifs >> time_out;
    ifs.ignore(20, ' ');
    ifs >> env_name;
    ifs.ignore(20, ' ');
    ifs >> env_dim[0] >> env_dim[1] >> env_dim[2];
    ifs.ignore(20, ' ');
    ifs >> do_viz;
    ifs.ignore(20, ' ');
    ifs >> do_realtime;
    ifs.ignore(20, ' ');
    ifs >> camera_pos[0] >> camera_pos[1] >> camera_pos[2] >> camera_pos[3] >> camera_pos[4] >> camera_pos[5];

    ifs.close();

}

std::ostream& operator<< (std::ostream &out, const SimulatorParams& sim_params) {
    out << "time_out: " << sim_params.time_out << std::endl
        << "env_name: " << sim_params.env_name << std::endl
        << "env_dim: "  << sim_params.env_dim[0] << " " << sim_params.env_dim[1] << " " << sim_params.env_dim[2] << std::endl
        << "do_viz: "   << sim_params.do_viz << std::endl
        << "do_realtime: " << sim_params.do_realtime << std::endl
        << "camera_pos: "  << sim_params.camera_pos[0] << " " << sim_params.camera_pos[1] << " " << sim_params.camera_pos[2] << " "
                           << sim_params.camera_pos[3] << " " << sim_params.camera_pos[4] << " " << sim_params.camera_pos[5] << std::endl;
    return out;
}

