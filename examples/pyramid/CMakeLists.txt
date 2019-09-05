
project(pyramid)
cmake_minimum_required(VERSION 3.0)


add_executable(pyramid pyramid.cpp)

target_include_directories(pyramid PRIVATE "${HALIDE_INCLUDE_DIR}" "${HALIDE_TOOLS_DIR}")
halide_use_image_io(pyramid)

# Define a halide_library() for each generator we have, and link each one into pyramid
file(GLOB GENS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/*_generator.cpp")
foreach(GEN_SRC ${GENS})
    string(REPLACE "_generator.cpp" "" GEN_NAME "${GEN_SRC}")
    halide_library("${GEN_NAME}" SRCS ${GEN_SRC})
    target_link_libraries(pyramid PUBLIC "${GEN_NAME}")
endforeach()
