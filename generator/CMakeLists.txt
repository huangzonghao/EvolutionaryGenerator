#######################################################################
#                               Targets                               #
#######################################################################
set(CURRENT_TARGET_NAME Generator)
set(Headers
    ${CMAKE_CURRENT_SOURCE_DIR}/include/EvoGenerator.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/EvoParams.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/GenerateDemoRobot.h
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
    ${CMAKE_CURRENT_SOURCE_DIR}/src/GenerateDemoRobot.cpp
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
        $<$<CONFIG:Debug>: /MD;>
        $<$<CONFIG:Release>: /MD;>
    )
endif()

set(CURRENT_TARGET_NAME robogami_test)

set(Headers
    ${PROJECT_IN_FILE_OUTPUT_DIR}/evo_paths.h
    ${PROJECT_IN_FILE_OUTPUT_DIR}/robogami_paths.h
    # include/UrdfExporter.h
    include/GenerateDemoRobot.h
)

set(Sources
    # src/UrdfExporter.cpp
    src/GenerateDemoRobot.cpp
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
