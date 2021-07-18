#include <iostream>

#include "RobogamiLibrary.h"

#include "evo_paths.h"
#include "robogami_paths.h"

int main(int argc, char *argv[]) {
    RobogamiLibrary robogami_lib(Robogami_Data_Dir + "/proto");
    robogami_lib.OutputMeshFiles(Robot_Output_Dir + "/tmp_robot_parts");
}
