#ifndef CHLINKBODIES_H_DHMRUNXO
#define CHLINKBODIES_H_DHMRUNXO
#include <chrono/physics/ChLink.h>
#include <chrono/physics/ChBody.h>

namespace chrono {

// ChLink stores only the raw pointer of ChBodyFrame
// So use this struct to store shared_ptr for the link and its bodies
struct ChLinkBodies{
    std::shared_ptr<ChLink> link;
    std::shared_ptr<ChBody> body1;
    std::shared_ptr<ChBody> body2;
};

} // namespace chrono

#endif /* end of include guard: CHLINKBODIES_H_DHMRUNXO */
