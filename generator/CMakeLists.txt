#######################################################################
#                               Targets                               #
#######################################################################
set(CURRENT_TARGET_NAME Generator)
set(Headers
    ${CMAKE_CURRENT_SOURCE_DIR}/include/EvoGenerator.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/EvoParams.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/RobogamiLibrary.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/RobotRepresentation.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/MeshInfo.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/GenerateDemoRobot.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/GenerateDemoRobogamiRobot.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/SimulatorParams.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/sferes_eval_EvoGenEval.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/include/sferes_fit_UrdfFitness.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/include/sferes_fit_RobogamiFitness.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/include/sferes_phen_EvoGenPhen.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/include/sferes_stat_EvoGenStat.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/include/sferes_ea_EvoGenEA.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/include/sferes_qd_EvoGenQD.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/include/sferes_qd_container_grid.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/include/sferes_qd_selector_uniform.hpp
    ${PROJECT_IN_FILE_OUTPUT_DIR}/evo_paths.h
    ${PROJECT_IN_FILE_OUTPUT_DIR}/robogami_paths.h
)

set(Sources
    ${CMAKE_CURRENT_SOURCE_DIR}/src/RobogamiLibrary.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/RobotRepresentation.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/MeshInfo.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/GenerateDemoRobot.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/GenerateDemoRobogamiRobot.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/EvoParams.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/SimulatorParams.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/EvoGenerator.cpp
)

add_library(${CURRENT_TARGET_NAME} STATIC ${Headers} ${Sources})

target_link_libraries(${CURRENT_TARGET_NAME}
                      FBE_Manipulations
                      FBE_Conversions
                      Boost::disable_autolinking
                      ${Boost_SERIALIZATION_LIBRARY_RELEASE}
                      Simulator
)

target_include_directories(${CURRENT_TARGET_NAME}
                           PUBLIC ${EIGEN3_INCLUDE_DIR}
                                  ${Boost_INCLUDE_DIR}
                                  ${PROJECT_IN_FILE_OUTPUT_DIR}
                                  ${CMAKE_CURRENT_SOURCE_DIR}/sferes_utils
                                  ${CMAKE_CURRENT_SOURCE_DIR}/include)

if(MSVC)
    source_group("Header Files" FILES ${Headers})
    source_group("Source Files" FILES ${Sources})
    target_compile_options(${CURRENT_TARGET_NAME} PRIVATE
        $<$<CONFIG:Debug>: /MD; /MP>
        $<$<CONFIG:Release>: /MP;>
    )
endif()

set(CURRENT_TARGET_NAME robogami_test)

set(Headers
    ${PROJECT_IN_FILE_OUTPUT_DIR}/evo_paths.h
    ${PROJECT_IN_FILE_OUTPUT_DIR}/robogami_paths.h
    # include/UrdfExporter.h
    include/RobogamiLibrary.h
    include/GenerateDemoRobot.h
    include/GenerateDemoRobogamiRobot.h
)

set(Sources
    # src/UrdfExporter.cpp
    src/RobogamiLibrary.cpp
    src/GenerateDemoRobot.cpp
    src/GenerateDemoRobogamiRobot.cpp
    src/robogami_test.cpp
)

add_executable(${CURRENT_TARGET_NAME} ${Headers} ${Sources})

target_include_directories(${CURRENT_TARGET_NAME}
                           PRIVATE ${PROJECT_IN_FILE_OUTPUT_DIR}
                                   ${CMAKE_CURRENT_SOURCE_DIR}/include
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
        $<$<CONFIG:Debug>: /W3; /MP; /MD; /JMC; /sdl;>
        $<$<CONFIG:Release>: /MP;>
    )
endif()

# copy DLLs for Windows
if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    set(CURRENT_TARGET_DEP_DLLS ${Protobuf_BIN_PATH}/libprotobuf.dll)
    list(APPEND CURRENT_TARGET_DEP_DLLS ${CPLEX_CPLEX_DLL})
    DLL_Copy_Command(${CURRENT_TARGET_NAME}_COPY_DLLS "${CURRENT_TARGET_DEP_DLLS}" ${CMAKE_CURRENT_BINARY_DIR})
endif()
