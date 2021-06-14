# Setup dependencies for urdf reader
find_package(urdfdom QUIET)
if (NOT urdfdom_FOUND)
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/urdfdom/.git")
        execute_process(COMMAND git submodule update --init --recursive --depth 1 -- thirdparty/urdfdom
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/urdfdom_headers/.git")
        execute_process(COMMAND git submodule update --init --recursive --depth 1 -- thirdparty/urdfdom_headers
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/console_bridge/.git")
        execute_process(COMMAND git submodule update --init --recursive --depth 1 -- thirdparty/console_bridge
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    endif()

    file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/urdfdom
                        ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/urdfdom_headers
                        ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/console_bridge
                        ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/tinyxml
                        ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/Install)

    execute_process(COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX:PATH=${PROJECT_DEP_INSTALL_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/urdfdom_headers
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/urdfdom_headers)

    execute_process(COMMAND ${CMAKE_COMMAND} --build . --config ${CMAKE_BUILD_TYPE} --target install
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/urdfdom_headers)

    execute_process(COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX:PATH=${PROJECT_DEP_INSTALL_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/console_bridge
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/console_bridge)

    execute_process(COMMAND ${CMAKE_COMMAND} --build . --config ${CMAKE_BUILD_TYPE} --target install
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/console_bridge)

    execute_process(COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX:PATH=${PROJECT_DEP_INSTALL_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/tinyxml
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/tinyxml)

    execute_process(COMMAND ${CMAKE_COMMAND} --build . --config ${CMAKE_BUILD_TYPE} --target install
                    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/thirdparty/tinyxml)

    if (WIN32) # Windows
        # set(ENV{CL} /D_USE_MATH_DEFINES $ENV{CL})
        # Need to do this due to a flaw of upstream library -- https://github.com/ros/urdfdom/issues/42
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/urdfdom_cmakelists_patched.txt DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/urdfdom/)
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/urdfparser_cmakelists_patched.txt DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/urdfdom/urdf_parser)
        file(RENAME ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/urdfdom/urdfdom_cmakelists_patched.txt ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/urdfdom/CMakeLists.txt)
        file(RENAME ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/urdfdom/urdf_parser/urdfparser_cmakelists_patched.txt ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/urdfdom/urdf_parser/CMakeLists.txt)
    endif()

    execute_process(COMMAND ${CMAKE_COMMAND}
                            -DCMAKE_INSTALL_PREFIX:PATH=${PROJECT_DEP_INSTALL_DIR}
                            -DTinyXML_ROOT_DIR:PATH=${PROJECT_DEP_INSTALL_DIR}
                            -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=True
                            ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/urdfdom
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

#######################################################################
#                               Targets                               #
#######################################################################
set(CURRENT_TARGET_NAME Simulator)

set(Headers
    include/ChRobot.h
    include/ChUrdfDoc.h
    include/ChRobogami.h
    include/RobotController.h
    include/SimMotor.h
    include/SimulationManager.h)

set(Sources
    src/ChUrdfDoc.cpp
    src/ChRobogami.cpp
    src/RobotController.cpp
    src/SimMotor.cpp
    src/SimulationManager.cpp)

add_library(${CURRENT_TARGET_NAME} STATIC ${Headers} ${Sources})

target_link_libraries(${CURRENT_TARGET_NAME}
                      ${CHRONO_LIBRARIES}
                      ${urdfdom_LIBRARIES}
                      FBE_Manipulations
                      FBE_Conversions)

target_include_directories(${CURRENT_TARGET_NAME}
                           PUBLIC ${EIGEN3_INCLUDE_DIR}
                                  ${urdfdom_INCLUDE_DIRS}
                                  ${CHRONO_INCLUDE_DIRS}
                                  ${CMAKE_CURRENT_SOURCE_DIR}/include)

set_target_properties(${CURRENT_TARGET_NAME} PROPERTIES
                      COMPILE_FLAGS "${CHRONO_CXX_FLAGS} ${EXTRA_COMPILE_FLAGS}"
                      COMPILE_DEFINITIONS "CHRONO_DATA_DIR=\"${CHRONO_DATA_DIR}\""
                      LINK_FLAGS "${CHRONO_LINKER_FLAGS}")

if(MSVC)
    source_group("Header Files" FILES ${Headers})
    source_group("Source Files" FILES ${Sources})
    target_compile_options(${CURRENT_TARGET_NAME} PRIVATE
        $<$<CONFIG:Debug>: /MD;>
        $<$<CONFIG:Release>: /MD;>
    )
endif()


set(CURRENT_TARGET_NAME chrono_test)

set(Headers ${PROJECT_IN_FILE_OUTPUT_DIR}/evo_paths.h)

set(Sources src/chrono_test.cpp)

add_executable(${CURRENT_TARGET_NAME} ${Headers} ${Sources})

target_link_libraries(${CURRENT_TARGET_NAME} Simulator)

target_include_directories(${CURRENT_TARGET_NAME} PRIVATE ${PROJECT_IN_FILE_OUTPUT_DIR})

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    file(GLOB CURRENT_TARGET_DEP_DLLS "${PROJECT_DEP_INSTALL_DIR}/bin/*.dll")
    list(APPEND CURRENT_TARGET_DEP_DLLS ${CHRONO_DLLS})
    set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR})
    DLL_Copy_Command(${CURRENT_TARGET_NAME}_COPY_DLLS "${CURRENT_TARGET_DEP_DLLS}" ${CMAKE_CURRENT_BINARY_DIR})
endif()

if(MSVC)
    source_group("Header Files" FILES ${Headers})
    source_group("Source Files" FILES ${Sources})
    target_compile_options(${CURRENT_TARGET_NAME} PRIVATE
        $<$<CONFIG:Debug>: /MD;>
        $<$<CONFIG:Release>: /MD;>
    )
endif()

set(CURRENT_TARGET_NAME memory_leak_test)

set(Sources src/memory_leak_test.cpp)

add_executable(${CURRENT_TARGET_NAME} ${Sources})

if(MSVC)
    source_group("Source Files" FILES ${Sources})
endif()

target_link_libraries(${CURRENT_TARGET_NAME} ${CHRONO_LIBRARIES})

target_include_directories(${CURRENT_TARGET_NAME} PUBLIC ${CHRONO_INCLUDE_DIRS})

set_target_properties(${CURRENT_TARGET_NAME} PROPERTIES
                      COMPILE_FLAGS "${CHRONO_CXX_FLAGS} ${EXTRA_COMPILE_FLAGS}"
                      COMPILE_DEFINITIONS "CHRONO_DATA_DIR=\"${CHRONO_DATA_DIR}\""
                      LINK_FLAGS "${CHRONO_LINKER_FLAGS}")
