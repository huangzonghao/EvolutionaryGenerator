cmake_minimum_required(VERSION 3.16)

project(Evolutionary_Generator)

#######################################################################
#                        Project Configuration                        #
#######################################################################
if(NOT DEFINED CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif()
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

if (NOT DEFINED PROJECT_IN_FILE_OUTPUT_DIR)
    set(PROJECT_IN_FILE_OUTPUT_DIR ${PROJECT_BINARY_DIR}/include CACHE PATH "Partial file output dir")
    file(MAKE_DIRECTORY ${PROJECT_IN_FILE_OUTPUT_DIR})
endif()

if (NOT DEFINED PROJECT_MATLAB_OUTPUT_DIR)
    set(PROJECT_MATLAB_OUTPUT_DIR ${PROJECT_BINARY_DIR}/Matlab CACHE PATH "Matlab scripts output dir")
    file(MAKE_DIRECTORY ${PROJECT_MATLAB_OUTPUT_DIR})
endif()

set(PROJECT_DEP_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/Install)
list(APPEND CMAKE_PREFIX_PATH ${PROJECT_DEP_INSTALL_DIR})

if (NOT DEFINED PROJECT_OUTPUT_DIR)
    set(PROJECT_OUTPUT_DIR ${PROJECT_BINARY_DIR}/Output CACHE PATH "Directory containing the program generated files")
    file(MAKE_DIRECTORY ${PROJECT_OUTPUT_DIR})
endif()

if (NOT DEFINED ROBOT_OUTPUT_DIR)
    set(ROBOT_OUTPUT_DIR ${PROJECT_OUTPUT_DIR}/Robots CACHE PATH "Directory containing the generated robots")
    file(MAKE_DIRECTORY ${ROBOT_OUTPUT_DIR})
endif()

if (NOT DEFINED RESULT_OUTPUT_DIR)
    set(RESULT_OUTPUT_DIR ${PROJECT_OUTPUT_DIR}/Results CACHE PATH "Directory containing the generated results")
    file(MAKE_DIRECTORY ${RESULT_OUTPUT_DIR})
endif()

if (NOT DEFINED MESH_WORKSPACE_DIR)
    set(MESH_WORKSPACE_DIR ${PROJECT_OUTPUT_DIR}/Meshes CACHE PATH "Directory containing the Meshes to be converted")
    file(MAKE_DIRECTORY ${MESH_WORKSPACE_DIR})
    file(MAKE_DIRECTORY ${MESH_WORKSPACE_DIR}/legs)
    file(MAKE_DIRECTORY ${MESH_WORKSPACE_DIR}/bodies)
    file(MAKE_DIRECTORY ${MESH_WORKSPACE_DIR}/maps)
endif()

if (NOT DEFINED EVOGEN_PARAMS_DIR)
    set(EVOGEN_PARAMS_DIR ${PROJECT_OUTPUT_DIR}/Params CACHE PATH "Directory containing the param files for EvoGen")
    file(MAKE_DIRECTORY ${EVOGEN_PARAMS_DIR})
endif()

# copy DLLs for Windows
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
include(DLL_Copy_Command)

set(ROBOT_PARTS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/resources/robot_parts)
set(EVOGEN_MAPS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/resources/maps)
set(PROJECT_IN_FILE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
set(RESOURCE_MAP_DIR ${CMAKE_CURRENT_SOURCE_DIR}/resources/maps)
set(EVOGEN_MATLAB_SCRIPTS_PATH ${CMAKE_CURRENT_SOURCE_DIR}/resources/matlab)
if (MSVC)
    set(EVOGEN_EXE_PATH ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE})
else()
    set(EVOGEN_EXE_PATH ${CMAKE_CURRENT_BINARY_DIR})
endif()
configure_file(${PROJECT_IN_FILE_DIR}/evo_paths.h.in ${PROJECT_IN_FILE_OUTPUT_DIR}/evo_paths.h @ONLY)
configure_file(${PROJECT_IN_FILE_DIR}/robot_design.m.in ${PROJECT_MATLAB_OUTPUT_DIR}/robot_design.m @ONLY)
configure_file(${PROJECT_IN_FILE_DIR}/result_analysis.m.in ${PROJECT_MATLAB_OUTPUT_DIR}/result_analysis.m @ONLY)

# Need to use the filesystem of C++17
set(CMAKE_CXX_STANDARD 17)

#######################################################################
#                         Setup Dependencies                          #
#######################################################################
# eigen3 find script doesn't work well on WIN32
if (UNIX)
    find_package(Eigen3 QUIET)
    if (NOT Eigen3_FOUND)
        message(SEND_ERROR "Error: Could not find Eigen3")
        message("  Set Eigen3_DIR to the directory that contains Eigen3Config.cmake")
        set(NEED_TO_RETURN True)
    else()
        message(STATUS "Eigen3 Found")
    endif()
elseif (WIN32)
    set(EIGEN3_INCLUDE_DIR "$ENV{EIGEN3_INCLUDE_DIR}" CACHE PATH "Eigen3 root directory")
    if (NOT EIGEN3_INCLUDE_DIR)
        message(SEND_ERROR "Error: Could not find Eigen3")
        message("  Set EIGEN3_INCLUDE_DIR to the root directory of your unzipped eigen library")
        set(NEED_TO_RETURN True)
    else()
        message(STATUS "Eigen3 Found")
    endif()
else()
    message(SEND_ERROR "Unknown system")
    return()
endif()

set(Boost_USE_STATIC_LIBS ON)
find_package(Boost COMPONENTS serialization)
if (NOT Boost_FOUND)
    message(SEND_ERROR "Could not find Boost, set BOOST_ROOT to the Boost base directory containing boost, libs, etc")
    set(BOOST_ROOT "Set Path To Boost Root" CACHE PATH "Boost base directory")
    set(NEED_TO_RETURN True)
    else()
        message(STATUS "Boost Found")
endif()

# The postprocess module is not required by this project, but somehow needed
# to avoid a 'postprocess dll not found' error when using the Chrono 6.0.0 installer.
find_package(Chrono
             COMPONENTS Irrlicht Vehicle Postprocess
             CONFIG QUIET)
if (NOT Chrono_FOUND)
    set(Chrono_DIR ${Chrono_DIR}/cmake)
    find_package(Chrono
                COMPONENTS Irrlicht Vehicle Postprocess
                CONFIG QUIET)
endif()
if (NOT Chrono_FOUND)
    message(SEND_ERROR "Error: Could not find Chrono or one of its required modules.")
    message("  Set Chrono_DIR to the directory that contains ChronoConfig.cmake")
    set(NEED_TO_RETURN True)
    else()
        message(STATUS "Chrono Found")
endif()

if (NEED_TO_RETURN)
    message("Some dependencies were not found. Set corresponding variables as mentioned above. If you use cmake-cli, edit entries in the CMakeCache.txt")
    return()
endif()

if(NOT DEFINED ROBOGAMI_DATA_PATH)
    if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/generator/Robogami/Data/.git)
        execute_process(COMMAND git submodule update --init --depth 1 -- generator/Robogami/Data
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
    set(ROBOGAMI_DATA_PATH ${CMAKE_CURRENT_SOURCE_DIR}/generator/Robogami/Data CACHE PATH "Path to the Robogami data repo root")
    message(STATUS "Robogami-Data Configured")
elseif(NOT EXISTS ${ROBOGAMI_DATA_PATH})
    message(SEND_ERROR "Error: Invalid Robogami-Data Path")
    set(ROBOGAMI_DATA_PATH "Path to Robogami data repo" CACHE PATH "Path to the Robogami data repo root" FORCE)
    set(NEED_TO_RETURN True)
else()
    message(STATUS "Robogami-Data Found")
endif()

if (NOT DEFINED RobogamiBackend_ROOT)
    if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/generator/Robogami/Backend/.git)
        execute_process(COMMAND git submodule update --init --depth 1 -- generator/Robogami/Backend
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
    set(RobogamiBackend_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/generator/Robogami/Backend CACHE PATH "Path to Robogami-Backend repo")
    message(STATUS "Robogami-Backend Configured")
elseif(NOT EXISTS ${RobogamiBackend_ROOT})
    message(SEND_ERROR "Error: Invalid Robogami-Backend Path")
    set(RobogamiBackend_ROOT "Path to Robogami-Backend repo" CACHE PATH "Path to Robogami-Backend repo" FORCE)
    set(NEED_TO_RETURN True)
else()
    message(STATUS "Robogami-Backend Found")
endif()

if (NOT DEFINED RobogamiUI_ROOT)
    if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/generator/Robogami/UI/.git)
        execute_process(COMMAND git submodule update --init --depth 1 -- generator/Robogami/UI
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
    set(RobogamiUI_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/generator/Robogami/UI CACHE PATH "Path to Robogami-UI repo")
    message(STATUS "Robogami-UI Configured")
elseif(NOT EXISTS ${RobogamiUI_ROOT})
    message(SEND_ERROR "Error: Invalid Robogami-UI Path")
    set(RobogamiUI_ROOT "Path to Robogami-UI repo" CACHE PATH "Path to Robogami-UI repo" FORCE)
    set(NEED_TO_RETURN True)
else()
    message(STATUS "Robogami-UI Found")
endif()

#######################################################################
#                           Subdirectories                            #
#######################################################################

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set(RobogamiBackend_GROUP_FOLDER Robogami)
add_subdirectory(generator/Robogami/Backend)
add_subdirectory(simulator)
add_subdirectory(generator)
set_target_properties(Generator Simulator PROPERTIES FOLDER Lib)

#######################################################################
#                               Targets                               #
#######################################################################

set(Headers
    ${PROJECT_IN_FILE_OUTPUT_DIR}/evo_paths.h
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/include/EvoGenerator.h
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/include/EvoParams.h
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/include/SimulatorParams.h
)
set(Sources ${CMAKE_CURRENT_SOURCE_DIR}/generator/src/evo_main.cpp)
add_executable(${PROJECT_NAME} ${Headers} ${Sources})
target_link_libraries(${PROJECT_NAME} Generator Simulator)
target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_IN_FILE_OUTPUT_DIR})
if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    # TODO: need to add cplex dll in debug config
    file(GLOB CURRENT_TARGET_DEP_DLLS "${PROJECT_DEP_INSTALL_DIR}/bin/*.dll")
    list(APPEND CURRENT_TARGET_DEP_DLLS ${CHRONO_DLLS})
    list(APPEND CURRENT_TARGET_DEP_DLLS ${Protobuf_BIN_PATH}/libprotobuf.dll)
    set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR})
    DLL_Copy_Command(${PROJECT_NAME}_COPY_DLLS "${CURRENT_TARGET_DEP_DLLS}" ${CMAKE_CURRENT_BINARY_DIR})
endif()
if(MSVC)
    source_group("Header Files" FILES ${Headers})
    source_group("Source Files" FILES ${Sources})
    target_compile_options(${PROJECT_NAME} PRIVATE
        $<$<CONFIG:Debug>: /W3; /MD; /MP; /JMC; /sdl;>
        $<$<CONFIG:Release>: /MP;>
    )
    target_compile_definitions(${PROJECT_NAME} PRIVATE
        $<$<CONFIG:Debug>:  _CRT_SECURE_NO_WARNINGS;>)
endif()

set(CURRENT_TARGET_NAME Export_Robotgami_Library)
set(Sources
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/src/RobogamiLibrary.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/src/export_robogami_library.cpp
)
add_executable(${CURRENT_TARGET_NAME} ${Sources})
target_link_libraries(${CURRENT_TARGET_NAME} PRIVATE robogami)
target_include_directories(${CURRENT_TARGET_NAME}
                           PUBLIC ${PROJECT_IN_FILE_OUTPUT_DIR}
                                  ${CMAKE_CURRENT_SOURCE_DIR}/generator/include)
if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    set(CURRENT_TARGET_DEP_DLLS ${Protobuf_BIN_PATH}/libprotobuf.dll)
    set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR})
    DLL_Copy_Command(${CURRENT_TARGET_NAME}_COPY_DLLS "${CURRENT_TARGET_DEP_DLLS}" ${CMAKE_CURRENT_BINARY_DIR})
endif()
if(MSVC)
    source_group("Header Files" FILES ${Headers})
    target_compile_options(${CURRENT_TARGET_NAME} PRIVATE
        $<$<CONFIG:Debug>: /W3; /MD; /MP; /JMC; /sdl;>
        $<$<CONFIG:Release>: /MP;>
    )
    target_compile_definitions(${CURRENT_TARGET_NAME} PRIVATE
        $<$<CONFIG:Debug>:  _CRT_SECURE_NO_WARNINGS;>)
endif()

set(CURRENT_TARGET_NAME Genotype_Visualizer)
set(Headers
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/include/MeshInfo.h
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/include/RobotRepresentation.h
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/include/GenerateDemoRobot.h
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/include/GenerateDemoRobogamiRobot.h
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/include/SimulatorParams.h
    ${PROJECT_IN_FILE_OUTPUT_DIR}/evo_paths.h
)
set(Sources
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/src/MeshInfo.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/src/RobotRepresentation.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/src/GenerateDemoRobot.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/src/GenerateDemoRobogamiRobot.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/src/SimulatorParams.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/src/visualizer_main.cpp
)
add_executable(${CURRENT_TARGET_NAME} ${Headers} ${Sources})
target_link_libraries(${CURRENT_TARGET_NAME} Generator Simulator)
target_include_directories(${CURRENT_TARGET_NAME} PRIVATE ${PROJECT_IN_FILE_OUTPUT_DIR})
if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    file(GLOB CURRENT_TARGET_DEP_DLLS "${PROJECT_DEP_INSTALL_DIR}/bin/*.dll")
    list(APPEND CURRENT_TARGET_DEP_DLLS ${CHRONO_DLLS})
    DLL_Copy_Command(${CURRENT_TARGET_NAME}_COPY_DLLS "${CURRENT_TARGET_DEP_DLLS}" ${CMAKE_CURRENT_BINARY_DIR})
endif()
if(MSVC)
    source_group("Header Files" FILES ${Headers})
    source_group("Source Files" FILES ${Sources})
    target_compile_options(${CURRENT_TARGET_NAME} PRIVATE
        $<$<CONFIG:Debug>: /W3; /MD; /MP; /JMC; /sdl;>
        $<$<CONFIG:Release>: /MP;>
    )
    target_compile_definitions(${CURRENT_TARGET_NAME} PRIVATE
        $<$<CONFIG:Debug>:  _CRT_SECURE_NO_WARNINGS;>)
endif()

set(CURRENT_TARGET_NAME Convert_Mesh_Models)
set(Sources
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/src/mesh_converter_main.cpp
)
add_executable(${CURRENT_TARGET_NAME} ${Sources})
target_link_libraries(${CURRENT_TARGET_NAME} trimesh2)
target_include_directories(${CURRENT_TARGET_NAME} PUBLIC ${PROJECT_IN_FILE_OUTPUT_DIR})
if(MSVC)
    source_group("Source Files" FILES ${Sources})
    target_compile_options(${CURRENT_TARGET_NAME} PRIVATE
        $<$<CONFIG:Debug>: /W3; /MD; /MP; /JMC; /sdl;>
        $<$<CONFIG:Release>: /MP;>
    )
    target_compile_definitions(${CURRENT_TARGET_NAME} PRIVATE
        $<$<CONFIG:Debug>:  _CRT_SECURE_NO_WARNINGS;>)
endif()

set(CURRENT_TARGET_NAME Show_Mesh_Info)
set(Sources ${CMAKE_CURRENT_SOURCE_DIR}/generator/src/show_mesh_info_main.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/generator/src/MeshInfo.cpp)
add_executable(${CURRENT_TARGET_NAME} ${Sources})
target_link_libraries(${CURRENT_TARGET_NAME} trimesh2)
target_include_directories(${CURRENT_TARGET_NAME} PUBLIC ${PROJECT_IN_FILE_OUTPUT_DIR}
                                                         ${CMAKE_CURRENT_SOURCE_DIR}/generator/include)
if(MSVC)
    source_group("Source Files" FILES ${Sources})
    target_compile_options(${CURRENT_TARGET_NAME} PRIVATE
        $<$<CONFIG:Debug>: /W3; /MD; /MP; /JMC; /sdl;>
        $<$<CONFIG:Release>: /MP;>
    )
endif()
