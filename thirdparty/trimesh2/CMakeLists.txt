project(trimesh2)

set(Headers
    include/bsphere.h
    include/endianutil.h
    include/lineqn.h
    include/mathcompat.h
    include/mathutil.h
    include/noise3d.h
    include/strutil.h
    include/timestamp.h
    include/Box.h
    include/Color.h
    include/GLCamera.h
    include/GLManager.h
    include/ICP.h
    include/KDtree.h
    include/TriMesh.h
    include/TriMesh_algo.h
    include/Vec.h
    include/XForm.h
)

set(Sources
    libsrc/conn_comps.cc
    libsrc/diffuse.cc
    libsrc/edgeflip.cc
    libsrc/faceflip.cc
    libsrc/filter.cc
    libsrc/make.cc
    libsrc/merge.cc
    libsrc/overlap.cc
    libsrc/remove.cc
    libsrc/reorder_verts.cc
    libsrc/subdiv.cc
    libsrc/umbrella.cc
    libsrc/GLCamera.cc
    libsrc/GLManager.cc
    libsrc/ICP.cc
    libsrc/KDtree.cc
    libsrc/TriMesh_bounding.cc
    libsrc/TriMesh_connectivity.cc
    libsrc/TriMesh_curvature.cc
    libsrc/TriMesh_grid.cc
    libsrc/TriMesh_io.cc
    libsrc/TriMesh_normals.cc
    libsrc/TriMesh_pointareas.cc
    libsrc/TriMesh_stats.cc
    libsrc/TriMesh_tstrips.cc
)

if (NOT TARGET ${PROJECT_NAME})
    add_library(${PROJECT_NAME} STATIC ${Headers} ${Sources})
    target_include_directories(${PROJECT_NAME} PUBLIC ${PROJECT_SOURCE_DIR}/include)
    set_target_properties(${PROJECT_NAME} PROPERTIES CXX_STANDARD 17)

    if(MSVC)
        target_compile_options(${PROJECT_NAME} PRIVATE
            $<$<CONFIG:Debug>: /JMC; /sdl; /MP; /MD; /wd4703;>
            $<$<CONFIG:Release>: /MP; /Oi; /GL; /Gy;>
            )
        target_compile_definitions(${PROJECT_NAME} PRIVATE _CRT_SECURE_NO_WARNINGS)
    endif()
endif()

