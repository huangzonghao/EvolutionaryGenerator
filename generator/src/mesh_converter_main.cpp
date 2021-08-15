#include <iostream>
#include <filesystem>
#include <TriMesh.h>
#include "robogami_paths.h"
#include "evo_paths.h"

// input: .stl
// output: .obj
void convert_stl_in_dir(const std::string& input_dir, const std::string& output_dir) {
    std::filesystem::path input_path(input_dir);
    if (!std::filesystem::exists(input_path)) {
        std::cout << "Error: " << input_dir << " doesn't exist" << std::endl;
        return;
    }
    const std::string in_ext(".stl");
    const std::string in_ext2(".STL");
    const std::string out_ext(".obj");

    // relocate the converted mesh
    bool converted_dir_not_created = true;
    std::string converted_dir;

    for (const auto& entry : std::filesystem::directory_iterator(input_path)) {
        const auto& tmp_path = entry.path();
        const auto& tmp_ext = tmp_path.extension().string();
        if (tmp_ext == in_ext || tmp_ext == in_ext2) {
            TriMesh *mesh = TriMesh::read(tmp_path.string().c_str());
            mesh->write(std::string(output_dir + "/" + tmp_path.stem().string() + out_ext).c_str());
            std::cout << tmp_path << " converted" << std::endl;
            delete mesh;
            if (converted_dir_not_created) {
                time_t t = time(0);
                char time_buffer [80];
                strftime(time_buffer, 80, "%Y%m%d_%H%M%S", localtime(&t));
                converted_dir = input_dir + "/Converted/" + time_buffer;
                std::filesystem::create_directories(converted_dir);
                converted_dir_not_created = false;
            }

            std::filesystem::rename(tmp_path, converted_dir + "/" + tmp_path.filename().string());
        }
    }
}

int main(int argc, char *argv[]) {
    // convert body stl
    convert_stl_in_dir(Mesh_Workspace_Dir + "/bodies", Robot_Parts_Dir + "/bodies");
    // convert leg stl
    convert_stl_in_dir(Mesh_Workspace_Dir + "/legs", Robot_Parts_Dir + "/legs");
    // convert env stl
    convert_stl_in_dir(Mesh_Workspace_Dir + "/maps", EvoGen_Maps_Dir);

    std::cout << "Mesh_Converter done" << std::endl;
    return 0;
}
