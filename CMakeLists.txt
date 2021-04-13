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
    file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/include)
    set(PROJECT_IN_FILE_OUTPUT_DIR ${PROJECT_BINARY_DIR}/include)
endif()

set(PROJECT_DEP_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/Install)
list(APPEND CMAKE_PREFIX_PATH ${PROJECT_DEP_INSTALL_DIR})

if (NOT DEFINED PROJECT_OUTPUT_DIR)
    file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/Output)
    set(PROJECT_OUTPUT_DIR ${PROJECT_BINARY_DIR}/Output)
endif()

if (NOT DEFINED ROBOT_OUTPUT_DIR)
    file(MAKE_DIRECTORY ${PROJECT_OUTPUT_DIR}/Robots)
    set(ROBOT_OUTPUT_DIR ${PROJECT_OUTPUT_DIR}/Robots)
endif()

if (NOT DEFINED RESULT_OUTPUT_DIR)
    file(MAKE_DIRECTORY ${PROJECT_OUTPUT_DIR}/Results)
    set(RESULT_OUTPUT_DIR ${PROJECT_OUTPUT_DIR}/Results)
endif()

# copy DLLs for Windows
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
include(DLL_Copy_Command)

set(PROJECT_IN_FILE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
set(RESOURCE_MAP_DIR ${CMAKE_CURRENT_SOURCE_DIR}/resources/maps)

configure_file(${PROJECT_IN_FILE_DIR}/evo_paths.h.in ${PROJECT_IN_FILE_OUTPUT_DIR}/evo_paths.h @ONLY)

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
find_package(Boost COMPONENTS serialization program_options thread date_time chrono timer filesystem)
if (NOT Boost_FOUND)
    message(SEND_ERROR "Could not find Boost, set BOOST_ROOT to the Boost base directory containing boost, libs, etc")
    set(BOOST_ROOT "Set Path To Boost Root" CACHE PATH "Boost base directory")
    set(NEED_TO_RETURN True)
    else()
        message(STATUS "Boost Found")
endif()

find_package(Chrono
             COMPONENTS Irrlicht Vehicle
             CONFIG QUIET)

if (NOT Chrono_FOUND)
    message(SEND_ERROR "Error: Could not find Chrono or one of its required modules.")
    message("  Set Chrono_DIR to the directory that contains ChronoConfig.cmake")
    set(NEED_TO_RETURN True)
    else()
        message(STATUS "Chrono Found")
endif()

find_package(TBB QUIET)
if (NOT TBB_FOUND)
    message(SEND_ERROR "Could not find TBB, set TBB_DIR to the directory where TBBConfig.cmake locates")
    set(NEED_TO_RETURN True)
    else()
        message(STATUS "TBB Found")
endif()

if (NEED_TO_RETURN)
    message("Some dependencies were not found. Set corresponding variables as mentioned above. If you use cmake-cli, edit entries in the CMakeCache.txt")
    return()
endif()

#######################################################################
#                           Subdirectories                            #
#######################################################################

add_subdirectory(simulator)
add_subdirectory(generator)

#######################################################################
#                               Targets                               #
#######################################################################

set(Headers
    # ${CMAKE_CURRENT_SOURCE_DIR}/generator/include/UrdfExporter.h
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/include/GenerateDemoRobot.h
    ${PROJECT_IN_FILE_OUTPUT_DIR}/evo_paths.h
    ${PROJECT_IN_FILE_OUTPUT_DIR}/robogami_paths.h
)

set(Sources
    # ${CMAKE_CURRENT_SOURCE_DIR}/generator/src/UrdfExporter.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/src/GenerateDemoRobot.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/generator/src/evo_main.cpp
)

add_executable(${PROJECT_NAME} ${Headers} ${Sources})

target_link_libraries(${PROJECT_NAME}
                      FBE_Manipulations
                      FBE_Printable
                      FBE_Conversions
                      TBB::tbb
                      Boost::serialization
                      Boost::program_options
                      Boost::thread
                      Boost::date_time
                      Boost::chrono
                      Boost::timer
                      Boost::filesystem
                      Simulator
)

target_include_directories(${PROJECT_NAME}
                           PUBLIC ${EIGEN3_INCLUDE_DIR}
                                  ${SFERES2_INCLUDE_DIR}
                                  ${PROJECT_IN_FILE_OUTPUT_DIR}
                                  ${CMAKE_CURRENT_SOURCE_DIR}/generator/include)

target_compile_definitions(${PROJECT_NAME} PRIVATE NO_PARALLEL)

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    file(GLOB CURRENT_TARGET_DEP_DLLS "${PROJECT_DEP_INSTALL_DIR}/bin/*.dll")
    list(APPEND CURRENT_TARGET_DEP_DLLS ${CHRONO_DLLS})
    list(APPEND CURRENT_TARGET_DEP_DLLS ${Protobuf_BIN_PATH}/libprotobuf.dll)
    get_target_property(TBB_DLL TBB::tbb IMPORTED_LOCATION_RELEASE)
    list(APPEND CURRENT_TARGET_DEP_DLLS ${TBB_DLL})
    set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR})
    DLL_Copy_Command(${PROJECT_NAME}_COPY_DLLS "${CURRENT_TARGET_DEP_DLLS}" ${CMAKE_CURRENT_BINARY_DIR})
endif()

if(MSVC)
    source_group("Header Files" FILES ${Headers})
    source_group("Source Files" FILES ${Sources})

    target_compile_options(${PROJECT_NAME} PRIVATE
        $<$<CONFIG:Debug>:
        # General
            /ZI;
            /JMC;
            /nologo;
            /W3;
            /WX-;
            /sdl;
            /MP;
        # Optimization
            /Od;
        # Code Generation
            /MD;
            /Gm-;
            /EHsc;
            /RTC1;
            /GS
        >
        $<$<CONFIG:Release>:
        # General
            /Zi;
            /nologo;
            /W3;
            /WX-;
            /MP;
        # Optimization
            /O2;
            /Oi;
        # Code Generation
            /Gm-;
            /EHsc;
            /MD;
            /GS;
            /Gy;
            ${DEFAULT_CXX_DEBUG_INFORMATION_FORMAT}
        >
        ${DEFAULT_CXX_EXCEPTION_HANDLING}
    )

    target_link_options(${PROJECT_NAME} PRIVATE /NOLOGO)
endif()
