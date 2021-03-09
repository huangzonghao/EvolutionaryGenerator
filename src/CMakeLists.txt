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

set(Boost_USE_STATIC_LIBS ON)
find_package(Boost COMPONENTS serialization program_options thread date_time chrono timer filesystem)
if (NOT Boost_FOUND)
    message(SEND_ERROR "Could not find Boost, set BOOST_ROOT to the Boost base directory containing boost, libs, etc")
    set(BOOST_ROOT "Set Path To Boost Root" CACHE PATH "Boost base directory")
    set(NEED_TO_RETURN True)
    else()
        message(STATUS "Boost Found")
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
#                           Platform Flags                            #
#######################################################################

#--------------------------------------------------------------
# Enable creation of "application bundles" on MacOSX.
#--------------------------------------------------------------

# This is necessary for any Irrlicht-based project (like the example here).
# For OpenGL-based or non-graphics projects, this is optional and the block
# below can be removed (or else explcitly set CMAKE_MACOSX_BUNDLE to 'OFF').
#
# If creating application bundles, the build output will be named 'myexe.app'.
# Use the convenience script 'run_app.sh' available under 'contrib/appbundle-macosx/'
# to run:
#     start_demo.sh myexe.app

if(APPLE)
    set(CMAKE_MACOSX_BUNDLE ON)
endif()

#-----------------------------------------------------------------------------
# Fix for VS 2017 15.8 and newer to handle alignment specification with Eigen
#-----------------------------------------------------------------------------

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  if(MSVC AND ${MSVC_VERSION} GREATER_EQUAL 1915)
    add_definitions( "-D_ENABLE_EXTENDED_ALIGNED_STORAGE" )
  endif()
endif()

#--------------------------------------------------------------
# Tweaks to disable some warnings with MSVC
#--------------------------------------------------------------
if(MSVC)
    add_definitions("-D_CRT_SECURE_NO_DEPRECATE")  # avoids deprecation warnings
    add_definitions("-D_SCL_SECURE_NO_DEPRECATE")  # avoids deprecation warnings
    add_definitions( "-DNOMINMAX" )                # do not use MSVC's min/max macros
    set(EXTRA_COMPILE_FLAGS "/wd4275")             # disable warnings triggered by Irrlicht
else()
    set(EXTRA_COMPILE_FLAGS "")
endif()

# Visual Studio compiler with static runtime libraries
if(MSVC AND MT)
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MTd")
endif()

# Need to use the filesystem of C++17
set (CMAKE_CXX_STANDARD 17)


#######################################################################
#                               Targets                               #
#######################################################################

set(CURRENT_TARGET_NAME sferes_test)
add_executable(${CURRENT_TARGET_NAME} sferes_test.cpp)
target_include_directories(${CURRENT_TARGET_NAME}
                           PRIVATE ${SFERES2_INCLUDE_DIR}
                                   ${EIGEN3_INCLUDE_DIR}
                                   ${Boost_INCLUDE_DIRS}
)

target_compile_definitions(${CURRENT_TARGET_NAME} PRIVATE NO_PARALLEL)

target_link_libraries(${CURRENT_TARGET_NAME}
                      PRIVATE TBB::tbb
                              Boost::serialization
                              Boost::program_options
                              Boost::thread
                              Boost::date_time
                              Boost::chrono
                              Boost::timer
                              Boost::filesystem
)

# copy DLLs for Windows
list(APPEND CMAKE_MODULE_PATH ${RobogamiBackend_ROOT}/cmake)
include(DLL_Copy_Command)
if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    get_target_property(TBB_DLL TBB::tbb IMPORTED_LOCATION_RELEASE)
    DLL_Copy_Command(${CURRENT_TARGET_NAME}_COPY_DLLS "${TBB_DLL}" ${CMAKE_CURRENT_BINARY_DIR})
endif()
