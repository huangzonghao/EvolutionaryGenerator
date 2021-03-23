#include <iostream>

#include "UrdfExporter.h"

#include "robogami_paths.h"

int main(int argc, char *argv[]) {
    protoToUrdf(Robogami_Data_Dir + "/proto/examples/killerBasket_good_servospacing.asciiproto", "killer");

    std::cout << "robogami test done" << std::endl;
    system("pause");
}
