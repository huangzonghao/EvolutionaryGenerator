#include <vector>
#include <thread>
#include <chrono/physics/ChSystemNSC.h>

using namespace chrono;

void dumb_test() {
    ChSystemNSC my_sys;
    while(my_sys.GetChTime() < 30)
        my_sys.DoStepDynamics(0.005);
}

int main() {
    std::vector<std::thread> threads;
    // int num_threads = std::thread::hardware_concurrency();
    int num_threads = 1;
    threads.reserve(num_threads);

    for (int i = 0; i < 2000; ++i) {
        for (int j = 0; j < num_threads; ++j) {
            threads.emplace_back(dumb_test);
        }
        for (auto& t : threads)
            t.join();

        threads.clear();
        std::cout << i << std::endl;
    }
}
