cmake_minimum_required(VERSION 3.10)
project(runner LANGUAGES CXX)

set(BINARY_NAME "avatar_studio")
set(APPLICATION_ID "com.taitanic.avatarstudio")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(SET CMP0063 NEW)

# Load bundled libraries from the lib directory relative to the binary.
set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Root filesystem for cross-building.
if(SYSROOT_DIR)
  set(CMAKE_SYSROOT ${SYSROOT_DIR})
endif()

# Version information
set(FLUTTER_TARGET_PLATFORM "linux-x64")

# Application build
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
)

# Apply the standard set of build settings. This can be changed as needed.
apply_standard_settings(${BINARY_NAME})

target_compile_definitions(${BINARY_NAME} PRIVATE
  APPLICATION_ID="${APPLICATION_ID}"
  BINARY_NAME="${BINARY_NAME}"
)

# Target options
target_include_directories(${BINARY_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}"
)

target_link_libraries(${BINARY_NAME} PRIVATE
  flutter
  gtk+-3.0
)
