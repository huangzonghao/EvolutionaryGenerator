# Project Setup on Windows

## Dependencies

### Robogami
Follow the [Robogami Installation Instruction](./Robogami/Backend/readme.md)

### Chrono
* Clone the Project Chrono [repo](https://github.com/projectchrono/chrono.git)
* Follow [these instructions](http://api.projectchrono.org/tutorial_install_chrono.html) to compile the project
* You could either choose to install Chrono to the installation directory, or simply leave Chrono in the build directory. The choice here would affect `Chrono_DIR` which would be used later.

## Compile Project
* This project is managed by CMake and requires a minimum CMake version of 3.16
* Make a build directory.
* Launch CMake and set the source and build directories to the correct location.
* Following the prompts of the CMake output to link external dependencies to the project.

## Project Structure
The project would generate 4 executable targets:
* `sferes_test`
* `robogami_test`
* `chrono_test`
* `Evolutionary_Generator`

If any "dll not found" error occurred when executing a binary, build the corresponding `COPY_DLLS` target. This will copy the required dlls to the right location.
