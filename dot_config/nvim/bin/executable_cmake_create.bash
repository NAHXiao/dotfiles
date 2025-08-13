#!/bin/bash
PROJECT_NAME=${1:-"NewProject"}
uname -a |grep -iq windows && IS_WIN=true
if test $IS_WIN;then
    VCPKG_TARGET_TRIPLET="x64-windows"
else
    VCPKG_TARGET_TRIPLET="x64-linux"
fi

mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"
mkdir "src"
cat > src/main.cpp << 'EOF'
#include <iostream>
int main() {
    std::cout << "Hello, CMake!" << std::endl;
    return 0;
}
EOF

cat > CMakeLists.txt <<-'EOF'
cmake_minimum_required(VERSION 3.24)
#set(VCPKG_TARGET_TRIPLET "VCPKG_TARGET_TRIPLET_PLACEHOLDER")
#set(CMAKE_TOOLCHAIN_FILE $ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake) # before project() command
project(PROJECT_NAME_PLACEHOLDER VERSION 0.1.0 LANGUAGES CXX)
#find_package(fmt CONFIG REQUIRED) # after project() command
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)


set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")
# set(CMAKE_CXX_COMPILER "/usr/bin/g++")


add_executable(${PROJECT_NAME} src/main.cpp)
#target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt)


execute_process(
  COMMAND ${CMAKE_COMMAND} -E create_symlink
    "${CMAKE_BINARY_DIR}/compile_commands.json"
    "${CMAKE_SOURCE_DIR}/compile_commands.json"
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
)
EOF

sed -i "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" CMakeLists.txt
sed -i "s/VCPKG_TARGET_TRIPLET_PLACEHOLDER/$VCPKG_TARGET_TRIPLET/g" CMakeLists.txt

mkdir build
cmake -S . -B build
cmake --build build
