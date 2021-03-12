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

# Setup dependencies for urdf reader
find_package(urdfdom QUIET)
if (NOT urdfdom_FOUND)
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/urdfdom/.git")
        execute_process(COMMAND git submodule update --init --recursive --depth 1 -- thirdparty/urdfdom
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/..)
    endif()
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/urdfdom_headers/.git")
        execute_process(COMMAND git submodule update --init --recursive --depth 1 -- thirdparty/urdfdom_headers
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/..)
    endif()
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/console_bridge/.git")
        execute_process(COMMAND git submodule update --init --recursive --depth 1 -- thirdparty/console_bridge
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/..)
    endif()

    file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/urdfdom
                        ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/urdfdom_headers
                        ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/console_bridge
                        ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/tinyxml
                        ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/Install)

    execute_process(COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX:PATH=${PROJECT_DEP_INSTALL_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/../thirdparty/urdfdom_headers
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/urdfdom_headers)

    execute_process(COMMAND ${CMAKE_COMMAND} --build . --config ${CMAKE_BUILD_TYPE} --target install
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/urdfdom_headers)

    execute_process(COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX:PATH=${PROJECT_DEP_INSTALL_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/../thirdparty/console_bridge
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/console_bridge)

    execute_process(COMMAND ${CMAKE_COMMAND} --build . --config ${CMAKE_BUILD_TYPE} --target install
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/console_bridge)

    execute_process(COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX:PATH=${PROJECT_DEP_INSTALL_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/../thirdparty/tinyxml
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/tinyxml)

    execute_process(COMMAND ${CMAKE_COMMAND} --build . --config ${CMAKE_BUILD_TYPE} --target install
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/tinyxml)

    if (WIN32) # Windows
        # set(ENV{CL} /D_USE_MATH_DEFINES $ENV{CL})
        # Need to do this due to a flaw of upstream library -- https://github.com/ros/urdfdom/issues/42
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/urdfdom_cmakelists_patched.txt DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/../thirdparty/urdfdom/)
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/urdfparser_cmakelists_patched.txt DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/../thirdparty/urdfdom/urdf_parser)
        file(RENAME ${CMAKE_CURRENT_SOURCE_DIR}/../thirdparty/urdfdom/urdfdom_cmakelists_patched.txt ${CMAKE_CURRENT_SOURCE_DIR}/../thirdparty/urdfdom/CMakeLists.txt)
        file(RENAME ${CMAKE_CURRENT_SOURCE_DIR}/../thirdparty/urdfdom/urdf_parser/urdfparser_cmakelists_patched.txt ${CMAKE_CURRENT_SOURCE_DIR}/../thirdparty/urdfdom/urdf_parser/CMakeLists.txt)
    endif()

    execute_process(COMMAND ${CMAKE_COMMAND}
                            -DCMAKE_INSTALL_PREFIX:PATH=${PROJECT_DEP_INSTALL_DIR}
                            -DTinyXML_ROOT_DIR:PATH=${PROJECT_DEP_INSTALL_DIR}
                            -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=True
                            ${CMAKE_CURRENT_SOURCE_DIR}/../thirdparty/urdfdom
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/urdfdom)

    execute_process(COMMAND ${CMAKE_COMMAND} --build . --config ${CMAKE_BUILD_TYPE} --target install
                    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/thirdparty/urdfdom")

    mark_as_advanced(console_bridge_DIR)
    mark_as_advanced(urdfdom_DIR)
    mark_as_advanced(urdfdom_headers_DIR)

    find_package(urdfdom QUIET)
else()
    message(STATUS "urdfdom Found")
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

set(CURRENT_TARGET_NAME robogami_test)

set(Headers
    ${PROJECT_IN_FILE_OUTPUT_DIR}/evo_paths.h
    ${PROJECT_IN_FILE_OUTPUT_DIR}/robogami_paths.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../include/UrdfExporter.h
)
set(Sources
    UrdfExporter.cpp
    robogami_test.cpp
)

add_executable(${CURRENT_TARGET_NAME} ${Headers} ${Sources})

target_include_directories(${CURRENT_TARGET_NAME}
                           PRIVATE ${PROJECT_IN_FILE_OUTPUT_DIR}
                                   ${CMAKE_CURRENT_SOURCE_DIR}/../include
)

target_link_libraries(${CURRENT_TARGET_NAME}
                      FBE_Manipulations
                      FBE_Printable
                      FBE_Conversions
)

if(MSVC)
    source_group("Header Files" FILES ${Headers})
    source_group("Source Files" FILES ${Sources})

    target_compile_options(${CURRENT_TARGET_NAME} PRIVATE
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

    target_link_options(${CURRENT_TARGET_NAME} PRIVATE /NOLOGO)
endif()

# copy DLLs for Windows
if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    set(CURRENT_TARGET_DEP_DLLS ${Protobuf_BIN_PATH}/libprotobuf.dll)
    DLL_Copy_Command(${CURRENT_TARGET_NAME}_COPY_DLLS "${CURRENT_TARGET_DEP_DLLS}" ${CMAKE_CURRENT_BINARY_DIR})
endif()

set(CURRENT_TARGET_NAME chrono_test)

set(Headers
    ${CMAKE_CURRENT_SOURCE_DIR}/../include/ChUrdfDoc.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../include/SimulationManager.h)

set(Sources
    chrono_test.cpp
    ChUrdfDoc.cpp
    SimulationManager.cpp)

if(MSVC)
    source_group("Header Files" FILES ${Headers})
    source_group("Source Files" FILES ${Sources})
endif()

add_executable(${CURRENT_TARGET_NAME} ${Headers} ${Sources})

target_link_libraries(${CURRENT_TARGET_NAME}
                      ${CHRONO_LIBRARIES}
                      ${urdfdom_LIBRARIES})

target_include_directories(${CURRENT_TARGET_NAME}
                           PUBLIC ${EIGEN3_INCLUDE_DIR}
                                  ${urdfdom_INCLUDE_DIRS}
                                  ${CHRONO_INCLUDE_DIRS}
                                  ${PROJECT_IN_FILE_OUTPUT_DIR}
                                  ${CMAKE_CURRENT_SOURCE_DIR}/../include)

set_target_properties(${CURRENT_TARGET_NAME} PROPERTIES
                      COMPILE_FLAGS "${CHRONO_CXX_FLAGS} ${EXTRA_COMPILE_FLAGS}"
                      COMPILE_DEFINITIONS "CHRONO_DATA_DIR=\"${CHRONO_DATA_DIR}\""
                      LINK_FLAGS "${CHRONO_LINKER_FLAGS}")

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    file(GLOB CURRENT_TARGET_DEP_DLLS "${PROJECT_DEP_INSTALL_DIR}/bin/*.dll")
    list(APPEND CURRENT_TARGET_DEP_DLLS ${CHRONO_DLLS})
    set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR})
    DLL_Copy_Command(${CURRENT_TARGET_NAME}_COPY_DLLS "${CURRENT_TARGET_DEP_DLLS}" ${CMAKE_CURRENT_BINARY_DIR})
endif()
