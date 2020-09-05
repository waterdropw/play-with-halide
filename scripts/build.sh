#!/bin/bash

CURRENT_DIR=`pwd`
HOST=`uname -sm`
TARGET_OS=$1
HOST_SYSTEM=`uname`
CPU_CORES=4

SRC_DIR=`pwd`
ABI_DIR=x64-Release

if [[ -z ${TARGET_OS} ]]; then
    TARGET_OS=${HOST_SYSTEM}
fi
if [[ ${TARGET_OS} == "Android" || ${TARGET_OS} == "android" ]]; then
    TARGET_OS="Android"
    ABI_DIR=$ANDROID_ABI
fi

if [[ ${HOST_SYSTEM} == "Linux" ]]; then
    CPU_CORES=`cat /proc/cpuinfo |grep "processor"|wc -l`
elif [[ ${HOST_SYSTEM} == "Darwin" ]]; then
    CPU_CORES=`sysctl -n hw.physicalcpu`
fi

if [[ ! -e "${Halide_DIR}" ]]; then
    if [[ -e "${HALIDE_ROOT_DIR}" ]]; then
        echo "Use Halide_DIR=$HALIDE_ROOT_DIR"
        echo
        Halide_DIR=`echo $HALIDE_ROOT_DIR`
    else
        echo "Use local build target"
        echo
        Halide_DIR=$HALIDE_TARGET_DIR/$TARGET_OS/$ABI_DIR/lib/cmake/Halide
    fi
    if [[ ! -e "${Halide_DIR}" ]]; then
        echo "Error: Halide_DIR=$Halide_DIR DOES NOT exist"
        exit
    fi
fi

INSTALL_ROOT=out/install/${TARGET_OS}
BUILD_ROOT=out/build/${TARGET_OS}
# HALIDE_TARGET_DIR=out/Halide/distrib


echo "*** *** *** *** *** *** *** *** *** *** *** ***"
echo "Halide_DIR: ${Halide_DIR}"
echo "HOST_OS: ${HOST}"
echo "TARGET_OS: ${TARGET_OS}"
echo "CPU_CORES: ${CPU_CORES}"
echo "SRC Dir: ${SRC_DIR}"
echo "Build Dir: ${BUILD_ROOT}"
echo "Install Dir: ${INSTALL_ROOT}"
echo "*** *** *** *** *** *** *** *** *** *** *** ***"


if [[ ${TARGET_OS} == "Android" ]]; then
    if [[ -d "$ANDROID_NDK" ]]; then
        echo "ANDROID_NDK=$ANDROID_NDK"
    elif [[ -d "$ANDROID_NDK_ROOT" ]]; then
        ANDROID_NDK=$ANDROID_NDK_ROOT
    elif [[ -d "$ANDROID_HOME" ]]; then
        ANDROID_NDK=$ANDROID_HOME/ndk-bundle
    fi
    
    if [[ -d "$ANDROID_SDK" ]]; then
        echo "ANDROID_SDK=$ANDROID_SDK"
    elif [[ -d "$ANDROID_HOME" ]]; then
        ANDROID_SDK=$ANDROID_HOME
    fi

    if [[ ! -e "${ANDROID_NDK}" ]]; then
        echo "Error: ANDROID_NDK is not fuond"
        exit
    fi
    if [[ ! -e "${ANDROID_SDK}" ]]; then
        echo "Error: ANDROID_SDK is not found"
        exit
    fi
fi

CMAKE_CONFIG="-G "Ninja" \\
    -D CMAKE_INSTALL_PREFIX=${INSTALL_DIR} \\
    -D CMAKE_BUILD_TYPE=Release \\
    -D Halide_DIR=${Halide_DIR} \\
    -D CMAKE_POSITION_INDEPENDENT_CODE=ON "
    
if [[ ${TARGET_OS} == "Android" ]]; then
    CMAKE_CONFIG="${CMAKE_CONFIG} \\
    -D CMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake \\
    -D ANDROID_SDK=${ANDROID_SDK} \\
    -D ANDROID_NDK=${ANDROID_NDK} \\
    -D ANDROID_PLATFORM=android-28 \\
    -D ANDROID_STL=c++_static \\
    -D ANDROID_PIE=ON "
fi

if [[ ${TARGET_OS} == "Android" ]]; then
    BUILD_DIR=${BUILD_ROOT}/arm
    cmake ${CMAKE_CONFIG} -D ANDROID_ABI="armeabi-v7a with NEON" -B ${BUILD_DIR} .
    cmake --build ${BUILD_DIR} --config Release --target install -- -j${CPU_CORES}

    BUILD_DIR=${BUILD_ROOT}/aarch64
    cmake ${CMAKE_CONFIG} -D ANDROID_ABI="arm64-v8a" -B ${BUILD_DIR} .
    cmake --build ${BUILD_DIR} --config Release --target install -- -j${CPU_CORES}
else
    # Debug vs Release has no difference!!!
    # BUILD_DIR=${BUILD_ROOT}/x64-Debug
    # INSTALL_DIR=${INSTALL_ROOT}/x64-Debug
    # cmake ${CMAKE_CONFIG} -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -B ${BUILD_DIR} .
    # cmake --build ${BUILD_DIR} --config Debug --target install -- -j${CPU_CORES}

    BUILD_DIR=${BUILD_ROOT}/x64-Release
    INSTALL_DIR=${INSTALL_ROOT}/x64-Release
    cmake ${CMAKE_CONFIG} -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -B ${BUILD_DIR} .
    cmake --build ${BUILD_DIR} --config Release --target install -- -j${CPU_CORES}
fi
