cmake_minimum_required(VERSION 3.16)

project(Evolutionary_Generator)

#######################################################################
#                        Project Configuration                        #
#######################################################################
if(NOT DEFINED CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif()
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

if(NOT DEFINED ROBOGAMI_DATA_PATH)
    if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/Robogami/Data/.git)
        execute_process(COMMAND git submodule update --init --depth 1 -- Data
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
    set(ROBOGAMI_DATA_PATH ${CMAKE_CURRENT_SOURCE_DIR}/Robogami/Data CACHE PATH "Path to the Robogami data repo root")
    message(STATUS "Robogami-Data Configured")
elseif(NOT EXISTS ${ROBOGAMI_DATA_PATH})
    message(SEND_ERROR "Error: Invalid Robogami-Data Path")
    set(ROBOGAMI_DATA_PATH "Path to Robogami data repo" CACHE PATH "Path to the Robogami data repo root" FORCE)
    set(NEED_TO_RETURN True)
else()
    message(STATUS "Robogami-Data Found")
endif()

if (NOT DEFINED RobogamiBackend_ROOT)
    if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/Robogami/Backend/.git)
        execute_process(COMMAND git submodule update --init --depth 1 -- Robogami/Backend
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
    set(RobogamiBackend_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/Robogami/Backend CACHE PATH "Path to Robogami-Backend repo")
    message(STATUS "Robogami-Backend Configured")
elseif(NOT EXISTS ${RobogamiBackend_ROOT})
    message(SEND_ERROR "Error: Invalid Robogami-Backend Path")
    set(RobogamiBackend_ROOT "Path to Robogami-Backend repo" CACHE PATH "Path to Robogami-Backend repo" FORCE)
    set(NEED_TO_RETURN True)
else()
    message(STATUS "Robogami-Backend Found")
endif()

if (NOT DEFINED RobogamiUI_ROOT)
    if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/Robogami/UI/.git)
        execute_process(COMMAND git submodule update --init --depth 1 -- Robogami/UI
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
    set(RobogamiUI_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/Robogami/UI CACHE PATH "Path to Robogami-UI repo")
    message(STATUS "Robogami-UI Configured")
elseif(NOT EXISTS ${RobogamiUI_ROOT})
    message(SEND_ERROR "Error: Invalid Robogami-UI Path")
    set(RobogamiUI_ROOT "Path to Robogami-UI repo" CACHE PATH "Path to Robogami-UI repo" FORCE)
    set(NEED_TO_RETURN True)
else()
    message(STATUS "Robogami-UI Found")
endif()

if (NOT DEFINED SFERES2_INCLUDE_DIR)
    if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/sferes2/.git)
        execute_process(COMMAND git submodule update --init --depth 1 -- sferes2
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
    set(SFERES2_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/sferes2 CACHE PATH "sferes2 include directory")
    message(STATUS "sferes2 Configured")
else()
    message(STATUS "sferes2 Found")
endif()

#######################################################################
#                           Subdirectories                            #
#######################################################################
add_subdirectory(Robogami/Backend)

