#!/bin/bash

HOST=`uname -sm`
TARGET_OS=$1
HOST_SYSTEM=`uname`
CPU_CORES=4
if [[ -z ${TARGET_OS} ]]; then
    TARGET_OS=${HOST_SYSTEM}
fi
if [[ ${TARGET_OS} == "Android" || ${TARGET_OS} == "android" ]]; then
    TARGET_OS="Android"
fi

if [[ ${HOST_SYSTEM} == "Linux" ]]; then
    CPU_CORES=`cat /proc/cpuinfo |grep "processor"|wc -l`
elif [[ ${HOST_SYSTEM} == "Darwin" ]]; then
    CPU_CORES=`sysctl -n hw.physicalcpu`
elif [[ ${HOST_SYSTEM} == "Windows" ]]; then
    CPU_CORES=%NUMBER_OF_PROCESSORS%
fi

SRC_DIR=external/Halide
BUILD_ROOT=out/Halide/build/${TARGET_OS}
INSTALL_ROOT=out/Halide/distrib/${TARGET_OS}

echo "*** *** *** *** *** *** *** *** *** *** *** ***"
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
if [[ ! -e ${LLVM_DIR} ]]; then
    if [[ -e ${LLVM_HOME} ]]; then
        LLVM_DIR=${LLVM_HOME}/lib/cmake/llvm
    elif [[ -e ${LLVM_ROOT} ]]; then
        LLVM_DIR=${LLVM_ROOT}/lib/cmake/llvm
    fi
    if [[ ! -e ${LLVM_DIR} ]]; then
        echo "Error: LLVM_DIR is not found"
        exit
    fi
fi

CMAKE_CONFIG="-G "Ninja" \\
    -D LLVM_DIR=${LLVM_DIR} \\
    -D CMAKE_BUILD_TYPE=Release \\
    -D CMAKE_INSTALL_PREFIX=${INSTALL_DIR} \\
    -D BUILD_SHARED_LIBS=ON \\
    -D WITH_APPS=ON \\
    -D WITH_TESTS=ON \\
    -D WITH_TUTORIALS=ON \\
    -D WITH_PYTHON_BINDINGS=OFF \\
    -D CMAKE_POSITION_INDEPENDENT_CODE=ON"

if [[ ${TARGET_OS} == "Android" ]]; then
    CMAKE_CONFIG="${CMAKE_CONFIG} \\
    -D WITH_PYTHON_BINDINGS=OFF \\
    -D CMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake \\
    -D ANDROID_SDK=${ANDROID_SDK} \\
    -D ANDROID_NDK=${ANDROID_NDK} \\
    -D ANDROID_PLATFORM=android-28 \\
    -D ANDROID_STL=c++_static \\
    -D ANDROID_PIE=ON "
fi

if [[ ${TARGET_OS} == "Android" ]]; then

    BUILD_DIR=${BUILD_ROOT}/arm64-v8a
    INSTALL_DIR=${INSTALL_ROOT}/arm64-v8a
    cmake ${CMAKE_CONFIG} -DANDROID_ABI="arm64-v8a" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -B ${BUILD_DIR} ${SRC_DIR}
    cmake --build ${BUILD_DIR} --config Release --target install -- -j${CPU_CORES}

    BUILD_DIR=${BUILD_ROOT}/armeabi-v7a
    cmake ${CMAKE_CONFIG} -DANDROID_ABI="armeabi-v7a with NEON" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -B ${BUILD_DIR} ${SRC_DIR}
    cmake --build ${BUILD_DIR} --config Release --target install -- -j${CPU_CORES}

else

    BUILD_DIR=${BUILD_ROOT}/x64-Release
    INSTALL_DIR=${INSTALL_ROOT}/x64-Release
    # INSTALL_DIR=/usr/local
    cmake ${CMAKE_CONFIG} -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -B ${BUILD_DIR} ${SRC_DIR}
    cmake --build ${BUILD_DIR} --config Release --target install -- -j${CPU_CORES}

    # BUILD_DIR=${BUILD_ROOT}/x64-Debug
    # INSTALL_DIR=${INSTALL_ROOT}/x64-Debug
    # cmake ${CMAKE_CONFIG} -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -B ${BUILD_DIR} ${SRC_DIR}
    # cmake --build ${BUILD_DIR} --config Debug --target install -- -j${CPU_CORES}

fi
