#ifndef EVOGEN_GENERATOR_ROBOGAMILIBRARY_H_
#define EVOGEN_GENERATOR_ROBOGAMILIBRARY_H_

#include <array>
#include <FBE_Temp/template.h>

constexpr int robogami_lib_num_bodies = 5;
constexpr int robogami_lib_num_legs = 11;

class RobogamiLibrary {
  public:
    std::array <std::string, robogami_lib_num_bodies> body_names {
        "BodyBasic",
        "BodyCylinder",
        "BodyHex",
        "BodyShoe",
        "BodyTrain"
    };
    std::array <std::string, robogami_lib_num_legs> leg_names {
        "BeamBasic",
        "BeamConcave",
        "BeamHeart",
        "BeamHex",
        "BeamRhex",
        "BeamSlanted",
        "BeamStar",
        "BeamTriangle",
        "SingleBeam",
        "DoubleBeam",
        "TripleBeam"
    };

    RobogamiLibrary(){}
    RobogamiLibrary(const std::string& lib_path){ LoadLibrary(lib_path); }
    bool LoadLibrary(const std::string& lib_path);
    std::shared_ptr<FabByExample::Template> GetBody(size_t idx) const;
    std::shared_ptr<FabByExample::Template> GetBody(const std::string& name) const;
    std::shared_ptr<FabByExample::Template> GetLeg(size_t idx) const;
    std::shared_ptr<FabByExample::Template> GetLeg(const std::string& name) const;
    // the mesh objects would be relocated that the center of bbox be at the origin of the frame
    // and repositioned from Y-up to Z-up
    void OutputMeshFiles(const std::string& output_path, const std::string& mesh_type = "obj");
    size_t GetBodyCount() { return body_names.size(); }
    size_t GetLegCount() { return leg_names.size(); }

  private:
    std::array<std::shared_ptr<FabByExample::Template>, robogami_lib_num_bodies> body_templates_;
    std::array<std::shared_ptr<FabByExample::Template>, robogami_lib_num_legs> leg_templates_;

};

#endif /* end of include guard: EVOGEN_GENERATOR_ROBOGAMILIBRARY_H_ */
