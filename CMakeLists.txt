cmake_minimum_required(VERSION 3.15)
project(CoolPropMEX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ---------------------------------------------------------------------------
# CoolProp shared library (built from submodule)
# ---------------------------------------------------------------------------
set(COOLPROP_SHARED_LIBRARY ON  CACHE BOOL "" FORCE)
set(COOLPROP_STATIC_LIBRARY OFF CACHE BOOL "" FORCE)
set(COOLPROP_OBJECT_LIBRARY OFF CACHE BOOL "" FORCE)
set(COOLPROP_NO_EXAMPLES    ON  CACHE BOOL "" FORCE)
set(BUILD_TESTING           OFF CACHE BOOL "" FORCE)

add_subdirectory(CoolProp EXCLUDE_FROM_ALL)

# ---------------------------------------------------------------------------
# MATLAB MEX support
# ---------------------------------------------------------------------------
find_package(Matlab REQUIRED COMPONENTS MX_LIBRARY)

# ---------------------------------------------------------------------------
# Helper macro: create one MEX target
# ---------------------------------------------------------------------------
macro(add_mex_target MEX_NAME)
    matlab_add_mex(
        NAME    ${MEX_NAME}
        SRC     src/${MEX_NAME}.cpp
        NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES
    )

    target_link_directories(${MEX_NAME} PRIVATE
        "${Matlab_ROOT_DIR}/bin/glnxa64"
    )

    if(UNIX AND NOT APPLE)
        target_link_libraries(${MEX_NAME}
            CoolProp
            mex
            mx
        )
    else()
        target_link_libraries(${MEX_NAME}
            CoolProp
            Matlab::mex
            Matlab::mx
        )
    endif()

    target_include_directories(${MEX_NAME} PRIVATE include)

    # Compiler flags
    if(MSVC)
        target_compile_options(${MEX_NAME} PRIVATE /utf-8)
    else()
        target_compile_options(${MEX_NAME} PRIVATE -fPIC)
    endif()

    # Apple Silicon: resolve weak MATLAB symbols at link time
    if(APPLE)
        target_link_options(${MEX_NAME} PRIVATE
            "-Wl,-U,_mexCreateMexFunction"
            "-Wl,-U,_mexDestroyMexFunction"
            "-Wl,-U,_mexFunctionAdapter"
            "-Wl,-ld_classic"
        )
    endif()

    # macOS: embed RPATH so libCoolProp.dylib and MATLAB's own libs are found
    # at runtime. Without BUILD_WITH_INSTALL_RPATH, CMake bakes in the
    # *build-tree* RPATH (absolute paths to wherever find_package(Matlab)
    # found MATLAB and where the CoolProp target was built — e.g. GitHub
    # Actions' /Users/runner/hostedtoolcache/... and /Users/runner/work/...
    # paths). These targets are never `cmake --install`ed (they're copied
    # straight to Release/ via RUNTIME_OUTPUT_DIRECTORY), so that build-tree
    # RPATH would otherwise ship permanently in the released binary and break
    # on every machine except the CI runner that built it.
    #   - @loader_path (macOS equivalent of Linux's $ORIGIN) resolves
    #     libCoolProp.dylib, which is copied next to the .mexmaca64.
    #   - libmex/libmx/libMatlabDataArray already resolve via the RPATH
    #     MATLAB's own process embeds for its bin/maca64 directory (inherited
    #     by dlopen through the loader chain), so we don't need our own entry
    #     for those.
    #   - libMatlabEngine.dylib, however, lives only in MATLAB's
    #     extern/bin/maca64, which is NOT covered by that inherited RPATH.
    #     @executable_path resolves to the directory of MATLAB's own main
    #     executable (bin/maca64) at runtime, wherever the end user installed
    #     MATLAB — so "@executable_path/../../extern/bin/maca64" reaches the
    #     sibling extern/bin/maca64 folder without hardcoding any install path.
    if(APPLE)
        set_target_properties(${MEX_NAME} PROPERTIES
            BUILD_WITH_INSTALL_RPATH TRUE
            INSTALL_RPATH            "@loader_path;@executable_path/../../extern/bin/maca64"
        )
    endif()

    # Linux: embed RPATH so the .so is found next to the .mexa64
    if(UNIX AND NOT APPLE)
        set_target_properties(${MEX_NAME} PROPERTIES
            BUILD_WITH_INSTALL_RPATH TRUE
            INSTALL_RPATH            "$ORIGIN"
        )
    endif()

    # Output all MEX files to Release/ at the repo root
    set_target_properties(${MEX_NAME} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY                "${CMAKE_SOURCE_DIR}/Release"
        RUNTIME_OUTPUT_DIRECTORY_RELEASE        "${CMAKE_SOURCE_DIR}/Release"
        RUNTIME_OUTPUT_DIRECTORY_DEBUG          "${CMAKE_SOURCE_DIR}/Release"
        LIBRARY_OUTPUT_DIRECTORY                "${CMAKE_SOURCE_DIR}/Release"
        LIBRARY_OUTPUT_DIRECTORY_RELEASE        "${CMAKE_SOURCE_DIR}/Release"
        LIBRARY_OUTPUT_DIRECTORY_DEBUG          "${CMAKE_SOURCE_DIR}/Release"
    )

    # Post-build: copy CoolProp shared library next to the MEX file
    if(WIN32)
        add_custom_command(TARGET ${MEX_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:CoolProp>
                "${CMAKE_SOURCE_DIR}/Release/"
            COMMENT "Copying CoolProp.dll to Release/"
        )
    elseif(APPLE)
        add_custom_command(TARGET ${MEX_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:CoolProp>
                "${CMAKE_SOURCE_DIR}/Release/"
            COMMENT "Copying libCoolProp.dylib to Release/"
        )
    else()
        # Copy the versioned .so (e.g. libCoolProp.so.8.1.0) and create the
        # soname symlink (libCoolProp.so.8) beside it so that the dynamic
        # linker can resolve it when MATLAB loads the MEX file from that dir.
        add_custom_command(TARGET ${MEX_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:CoolProp>
                "${CMAKE_SOURCE_DIR}/Release/"
            COMMAND ${CMAKE_COMMAND} -E create_symlink
                $<TARGET_FILE_NAME:CoolProp>
                "${CMAKE_SOURCE_DIR}/Release/$<TARGET_SONAME_FILE_NAME:CoolProp>"
            COMMAND ${CMAKE_COMMAND} -E create_symlink
                $<TARGET_FILE_NAME:CoolProp>
                "${CMAKE_SOURCE_DIR}/Release/$<TARGET_LINKER_FILE_NAME:CoolProp>"
            COMMENT "Copying libCoolProp.so + soname/linker symlinks to Release/"
        )
    endif()
endmacro()

# ---------------------------------------------------------------------------
# MEX targets
# ---------------------------------------------------------------------------
add_mex_target(PropsSI)
add_mex_target(HAPropsSI)
add_mex_target(AbstractStateMex)

# Copy AbstractState.m to Release/ (only needs to happen once, tie to AbstractStateMex)
add_custom_command(TARGET AbstractStateMex POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_SOURCE_DIR}/matlab/AbstractState.m"
        "${CMAKE_SOURCE_DIR}/Release/"
    COMMENT "Copying AbstractState.m to Release/"
)
