@echo off

if "%~1"=="" (
    set PROJECT_NAME=MyProject
) else (
    set PROJECT_NAME=%~1
)

mkdir "%PROJECT_NAME%"
cd "%PROJECT_NAME%"
mkdir "src"

(
echo #include ^<iostream^>
echo int main^(^) {
echo     std::cout ^<^< "Hello, CMake!" ^<^< std::endl;
echo     return 0;
echo }
) > src/main.cpp

(
echo cmake_minimum_required^(VERSION 3.24^)
echo #set^(VCPKG_TARGET_TRIPLET "x64-windows-static"^) 
echo #set^(CMAKE_TOOLCHAIN_FILE $ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake^) # before project^(^) command
echo project^(%PROJECT_NAME% VERSION 0.1.0 LANGUAGES CXX^)
echo #find_package^(fmt CONFIG REQUIRED^) # after project^(^) command
echo set^(CMAKE_EXPORT_COMPILE_COMMANDS ON^)
echo.
echo.
echo set^(CMAKE_CXX_STANDARD 17^)
echo set^(CMAKE_CXX_STANDARD_REQUIRED ON^)
echo set^(CMAKE_CXX_EXTENSIONS OFF^)
echo # set^(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall"^)
echo # set^(CMAKE_CXX_COMPILER "/usr/bin/g++"^)
echo.
echo.
echo add_executable^(${PROJECT_NAME} src/main.cpp^)
echo target_compile_definitions^(${PROJECT_NAME} PRIVATE FMT_HEADER_ONLY=0^)
echo #target_link_libraries^(${PROJECT_NAME} PRIVATE fmt::fmt^)
echo.
echo.
echo add_custom_command^(TARGET ${PROJECT_NAME} POST_BUILD
echo     COMMAND ${CMAKE_COMMAND} -E copy_if_different
echo         "${CMAKE_BINARY_DIR}/compile_commands.json"
echo         "${CMAKE_SOURCE_DIR}/compile_commands.json"
echo     COMMENT "Copying compile_commands.json to source directory"
echo ^)
) > CMakeLists.txt

mkdir build
cmake -S . -B build
cmake --build build
