cmake_minimum_required(VERSION 3.0)

project(play-with-halide)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

find_package(Halide)


option(BUILD_WITH_TUTORIALS "Build with tutorials" ON)
option(BUILD_WITH_EXAMPLES "Build with examples" ON)


set(CMAKE_MACOSX_RPATH ON)
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -pthread)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    # set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -ltinfo)
endif()

execute_process(COMMAND ${LLVM_CONFIG} --cxxflags OUTPUT_VARIABLE LLVM_CONFIG_CXXFLAGS)
string(FIND "${LLVM_CONFIG_CXXFLAGS}" "-std=c++17" LLVM_CPP17)
string(FIND "${LLVM_CONFIG_CXXFLAGS}" "-std=c++14" LLVM_CPP14)
if (LLVM_CPP17 GREATER -1)
    set(CMAKE_CXX_STANDARD 17)
elseif (LLVM_CPP14 GREATER -1)
    set(CMAKE_CXX_STANDARD 14)
else()
# Require (at least) C++11 for everything.
    set(CMAKE_CXX_STANDARD 11)
endif()

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)


set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")


add_subdirectory(utils)

if (BUILD_WITH_TUTORIALS)
    add_subdirectory(tutorial)
endif()

if (BUILD_WITH_EXAMPLES)
    add_subdirectory(examples)
endif()


include(CMakePrintHelpers)
cmake_print_variables(LLVM_CPP17)
cmake_print_variables(LLVM_CPP14)


##############################################
# Installation instructions
include(GNUInstallDirs)

list(APPEND TUTORIALS_EXE
    lesson_01_basics
    lesson_02_input_image
    lesson_03_debugging_1
    lesson_04_debugging_2
    lesson_05_scheduling_1
    lesson_06_realizing_over_shifted_domains
    lesson_07_multi_stage_pipelines
    lesson_08_scheduling_2
    lesson_09_update_definitions
    # lesson_10_aot_compilation_run
    lesson_11_cross_compilation
    lesson_12_using_the_gpu
    lesson_13_tuples
    lesson_14_types
    # lesson_15_targets
    # lesson_16_rgb_generate
    lesson_16_rgb_run
    lesson_17_predicated_rdom
    lesson_18_parallel_associative_reductions
    lesson_19_wrapper_funcs
    lesson_20_cloning_funcs
    lesson_21_auto_scheduler_run
)
foreach(tut ${TUTORIALS_EXE})
    install(TARGETS ${tut}
        EXPORT halide_tutorial-targets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}     # for Windows
    )
endforeach(tut)
