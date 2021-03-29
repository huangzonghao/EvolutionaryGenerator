# Evolutionary Generator

## Project Setup on Windows
### Dependencies

#### Robogami
Follow the [Robogami Installation Instruction](./Robogami/Backend/readme.md)

#### Chrono
* Clone the Project Chrono [repo](https://github.com/projectchrono/chrono.git)
* Follow [these instructions](http://api.projectchrono.org/tutorial_install_chrono.html) to compile the project
* You could either choose to install Chrono to the installation directory, or simply leave Chrono in the build directory. The choice here would affect `Chrono_DIR` which would be used later.

### Compile Project
* This project is managed by CMake and requires a minimum CMake version of 3.16
* Make a build directory.
* Launch CMake and set the source and build directories to the correct location.
* Following the prompts of the CMake output to link external dependencies to the project.

### Project Structure
The project would generate 4 executable targets:
* `sferes_test`
* `robogami_test`
* `chrono_test`
* `Evolutionary_Generator`

If any "dll not found" error occurred when executing a binary, build the corresponding `COPY_DLLS` target. This will copy the required dlls to the right location.

## Progress
### Overall
* [x] Glue dependencies together with CMake
* [x] Set up test projects for each component
* [x] Set up sferes - robogami - chrono loop
* [x] Define Internal APIs
    * [x] URDF
    * [ ] upgrade to protobuf
* [x] Specify Task - type/environment/dynamics
* [ ] Refactor code to easily pass simulation data to sferes2 (sferes2 doesn't take inputs)
* [ ] Design experiments
* [ ] Design evaluation metrics

### Robogami
* [ ] Set up UI
* [x] Enable text mode functionality
* [x] Export existing design
* [ ] Generate design with selected bodies
* [x] Define robot design vector
* [ ] Generate design based on design vector
* [ ] Serialize database
* [ ] Add new parts to database
* [ ] Define user input

### Sferes2
* [x] Solve simple test problem
* [x] Design algorithm structure
* [x] Define fitness
* [x] Implement algorithm
* [ ] Understand & tune parameters

### Simulation
* [x] Load environment - URDF/Height Map/Mesh Object
* [x] Load URDF robot
* [x] Add controller for pre-defined robot
* [ ] Generate trajectory
