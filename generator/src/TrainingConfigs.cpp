#include "TrainingConfigs.h"

bool EvoGenTrainingConfigs::Save(const std::string& filename) const {
    std::ofstream ofs(filename);
    if (!ofs) {
        std::cerr << "Error: Could not create file " << filename << std::endl;
        return false;
    }
    boost::archive::xml_oarchive oa(ofs);
    oa << boost::serialization::make_nvp("EvoGenTrainingConfigs", *this);
    return true;
}

bool EvoGenTrainingConfigs::Load(const std::string& filename) {
    std::ifstream ifs(filename);
    if (!ifs) {
        std::cerr << "Error: Could not open file " << filename << std::endl;
        return false;
    }
    boost::archive::xml_iarchive ia(ifs);
    ia >> boost::serialization::make_nvp("EvoGenTrainingConfigs", *this);
    return true;
}

void EvoGenTrainingConfigs::AddWaypoint(double x, double y, double z) {
    waypoints_.push_back(std::vector<double>{x,y,z});
}

void EvoGenTrainingConfigs::SetCamera(double from_x, double from_y, double from_z,
                                double to_x, double to_y, double to_z) {
    camera_pos[0] = from_x;
    camera_pos[1] = from_y;
    camera_pos[2] = from_z;
    camera_pos[3] = to_x;
    camera_pos[4] = to_y;
    camera_pos[5] = to_z;
}

std::string EvoGenTrainingConfigs::GetEnv() const {
    if (env_name.find('.') == std::string::npos)
        // return the env_name directly if it's not a filename
        return env_name;
    else
        return env_dir + "/" + env_name;
}

bool EvoGenTrainingConfigs::Save(const std::string& filename) const {
    std::ofstream ofs(filename);
    if (!ofs) {
        std::cerr << "Error: Could not create file " << filename << std::endl;
        return false;
    }
    boost::archive::xml_oarchive oa(ofs);
    oa << boost::serialization::make_nvp("EvoGenTrainingConfigs", *this);
    return true;
}

bool EvoGenTrainingConfigs::Load(const std::string& filename) {
    std::ifstream ifs(filename);
    if (!ifs) {
        std::cerr << "Error: Could not open file " << filename << std::endl;
        return false;
    }
    boost::archive::xml_iarchive ia(ifs);
    ia >> boost::serialization::make_nvp("EvoGenTrainingConfigs", *this);
    return true;
}

template<class Archive>
void EvoGenTrainingConfigs::serialize(Archive & ar, const unsigned int version) {
    ar & BOOST_SERIALIZATION_NVP(time_out);
    ar & BOOST_SERIALIZATION_NVP(env_name);
    ar & BOOST_SERIALIZATION_NVP(env_dim);
    ar & BOOST_SERIALIZATION_NVP(env_rot);
    ar & BOOST_SERIALIZATION_NVP(do_viz);
    ar & BOOST_SERIALIZATION_NVP(do_realtime);
    ar & BOOST_SERIALIZATION_NVP(camera_pos);
    ar & BOOST_SERIALIZATION_NVP(waypoints_);
}

std::ostream& operator<< (std::ostream &out, const EvoGenTrainingConfigs& sim_params) {
    out << "time_out: " << sim_params.time_out << std::endl
        << "env_name: " << sim_params.env_name << std::endl
        << "env_dim: "  << sim_params.env_dim[0] << ", " << sim_params.env_dim[1] << ", " << sim_params.env_dim[2] << std::endl
        << "env_rot: "  << sim_params.env_rot[0] << ", " << sim_params.env_rot[1] << ", " << sim_params.env_rot[2] << ", " << sim_params.env_rot[3] << std::endl
        << "do_viz: "   << sim_params.do_viz << std::endl
        << "do_realtime: " << sim_params.do_realtime << std::endl
        << "camera_pos: "  << sim_params.camera_pos[0] << ", " << sim_params.camera_pos[1] << ", " << sim_params.camera_pos[2] << ", "
                           << sim_params.camera_pos[3] << ", " << sim_params.camera_pos[4] << ", " << sim_params.camera_pos[5] << std::endl;
    if (!sim_params.waypoints_.empty()) {
        std::cout << "waypoints: " << std::endl;
        for (auto& wp : sim_params.waypoints_)
            std::cout << "    " << wp[0] << ", " << wp[1] << ", " << wp[2] << std::endl;
    }
    return out;
}

