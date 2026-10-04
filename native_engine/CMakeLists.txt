cmake_minimum_required(VERSION 3.10)
project(avatar_native_bridge C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

include_directories(include)

set(SOURCES
    src/avatar_vcam_linux.c
    src/avatar_telemetry.c
)

add_library(avatar_native_bridge SHARED ${SOURCES})

set_target_properties(avatar_native_bridge PROPERTIES
    OUTPUT_NAME "avatar_native_bridge"
    VERSION 1.0.0
    SOVERSION 1
)

# Install / output directory
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../Orange_flutter/Orange/build_native)
