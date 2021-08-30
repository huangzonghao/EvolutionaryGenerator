#include "MeshInfo.h"
#include "evo_paths.h"

extern MeshInfo mesh_info;
int main(int argc, char *argv[]) {
    mesh_info.set_mesh_dir(Robot_Parts_Dir);
    mesh_info.init();
    mesh_info.print_all_size();
    return 0;
}
