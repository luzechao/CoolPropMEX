cmake_minimum_required(VERSION 3.15)
project(CoolProp_MATLAB)

# Set C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find MATLAB
find_package(Matlab REQUIRED COMPONENTS MX_LIBRARY)

# Set root directory
set(ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../..")

# Set CoolProp library paths based on platform
if(WIN32)
    set(COOLPROP_SHARED_LIB "${ROOT_DIR}/build/Release/CoolProp.dll")
    set(COOLPROP_LIB "${ROOT_DIR}/build/Release/CoolProp.lib")
elseif(APPLE)
    set(COOLPROP_SHARED_LIB "${ROOT_DIR}/build/libCoolProp.dylib")
    set(COOLPROP_LIB "${ROOT_DIR}/build/libCoolProp.dylib")
else() # Linux
    set(COOLPROP_SHARED_LIB "${ROOT_DIR}/build/libCoolProp.so")
    set(COOLPROP_LIB "${ROOT_DIR}/build/libCoolProp.so")
endif()

# Include directories
include_directories(
    ${Matlab_INCLUDE_DIRS}
    ${ROOT_DIR}/include
    ${ROOT_DIR}/externals/fmtlib/include
)

# Create PropsSI MEX file
matlab_add_mex(
    NAME PropsSI
    SRC PropsSI.cpp
    LINK_TO ${COOLPROP_LIB}
)

# Add compiler flags
if(MSVC)
    target_compile_options(PropsSI PRIVATE /utf-8)
elseif(UNIX)
    target_compile_options(PropsSI PRIVATE -fPIC)
endif()

# Set output directory
set_target_properties(PropsSI PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
)

# Create HAPropsSI MEX file
matlab_add_mex(
    NAME HAPropsSI
    SRC HAPropsSI.cpp
    LINK_TO ${COOLPROP_LIB}
)

# Add compiler flags
if(MSVC)
    target_compile_options(HAPropsSI PRIVATE /utf-8)
elseif(UNIX)
    target_compile_options(HAPropsSI PRIVATE -fPIC)
endif()

# Set output directory
set_target_properties(HAPropsSI PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
)

# Create AbstractStateMex MEX file
matlab_add_mex(
    NAME AbstractStateMex
    SRC AbstractStateMex.cpp
    LINK_TO ${COOLPROP_LIB}
)

# Add compiler flags
if(MSVC)
    target_compile_options(AbstractStateMex PRIVATE /utf-8)
elseif(UNIX)
    target_compile_options(AbstractStateMex PRIVATE -fPIC)
endif()

# Set output directory
set_target_properties(AbstractStateMex PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
)

# Copy CoolProp shared library to output directory
if(WIN32)
    add_custom_command(TARGET PropsSI POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${COOLPROP_SHARED_LIB}"
        $<TARGET_FILE_DIR:PropsSI>
        COMMENT "Copying CoolProp shared library to output directory"
    )
    add_custom_command(TARGET HAPropsSI POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${COOLPROP_SHARED_LIB}"
        $<TARGET_FILE_DIR:HAPropsSI>
        COMMENT "Copying CoolProp shared library to output directory"
    )
    add_custom_command(TARGET AbstractStateMex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${COOLPROP_SHARED_LIB}"
        $<TARGET_FILE_DIR:AbstractStateMex>
        COMMENT "Copying CoolProp shared library to output directory"
    )
elseif(APPLE)
    add_custom_command(TARGET PropsSI POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${COOLPROP_SHARED_LIB}"
        $<TARGET_FILE_DIR:PropsSI>
        COMMENT "Copying CoolProp shared library to output directory"
    )
    add_custom_command(TARGET HAPropsSI POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${COOLPROP_SHARED_LIB}"
        $<TARGET_FILE_DIR:HAPropsSI>
        COMMENT "Copying CoolProp shared library to output directory"
    )
    add_custom_command(TARGET AbstractStateMex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${COOLPROP_SHARED_LIB}"
        $<TARGET_FILE_DIR:AbstractStateMex>
        COMMENT "Copying CoolProp shared library to output directory"
    )
else() # Linux
    # Set RPATH to find shared library at runtime
    set_target_properties(PropsSI PROPERTIES
        BUILD_WITH_INSTALL_RPATH TRUE
        INSTALL_RPATH "$ORIGIN"
    )
    set_target_properties(HAPropsSI PROPERTIES
        BUILD_WITH_INSTALL_RPATH TRUE
        INSTALL_RPATH "$ORIGIN"
    )
    set_target_properties(AbstractStateMex PROPERTIES
        BUILD_WITH_INSTALL_RPATH TRUE
        INSTALL_RPATH "$ORIGIN"
    )
    add_custom_command(TARGET PropsSI POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${COOLPROP_SHARED_LIB}"
        $<TARGET_FILE_DIR:PropsSI>
        COMMENT "Copying CoolProp shared library to output directory"
    )
    add_custom_command(TARGET HAPropsSI POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${COOLPROP_SHARED_LIB}"
        $<TARGET_FILE_DIR:HAPropsSI>
        COMMENT "Copying CoolProp shared library to output directory"
    )
    add_custom_command(TARGET AbstractStateMex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${COOLPROP_SHARED_LIB}"
        $<TARGET_FILE_DIR:AbstractStateMex>
        COMMENT "Copying CoolProp shared library to output directory"
    )
endif()

# Copy MATLAB helper class to output directory
add_custom_command(TARGET AbstractStateMex POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${CMAKE_CURRENT_SOURCE_DIR}/AbstractState.m"
    $<TARGET_FILE_DIR:AbstractStateMex>
    COMMENT "Copying AbstractState.m to output directory"
)
