#include "EvoParams.h"

#include <iostream>
#include <fstream>
#include <boost/archive/xml_oarchive.hpp>
#include <boost/archive/xml_iarchive.hpp>
#include <boost/serialization/vector.hpp>

bool EvoParams::Save(const std::string& filename) const {
    std::ofstream ofs(filename);
    if (!ofs) {
        std::cerr << "Error: Could not create file " << filename << std::endl;
        return false;
    }
    boost::archive::xml_oarchive oa(ofs);
    oa << boost::serialization::make_nvp("EvoParams", *this);
    return true;
}

bool EvoParams::Load(const std::string& filename) {
    std::ifstream ifs(filename);
    if (!ifs) {
        std::cerr << "Error: Could not open file " << filename << std::endl;
        return false;
    }
    boost::archive::xml_iarchive ia(ifs);
    ia >> boost::serialization::make_nvp("EvoParams", *this);
    return true;
}
