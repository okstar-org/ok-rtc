#!/bin/bash

# 检查操作系统类型
ARCH="arm64"

# 检查操作系统类型
OS=$(uname)
if [ "$OS" == "Darwin"  ];
then
    echo "Is MacOS build 。。。。"
else
    echo "Unsupported operating system: $OS"
    exit 1
fi
cd ../ || exit
WORKSPACE_CURRENT=$(pwd)
echo ">>>> WORKSPACE_CURRENT = ${WORKSPACE_CURRENT}"

function build_openh264() {
    local third_party_path="${WORKSPACE_CURRENT}/src/third_party"
    local OPENH264_PATH="${third_party_path}/openh264"
    cd "${OPENH264_PATH}" || exit
    make OS=ios ARCH=${ARCH} clean
    make OS=ios ARCH=${ARCH}
    make OS=ios ARCH=${ARCH} install-static
    cd "${WORKSPACE_CURRENT}" || exit
}
function build_crc32c() {
    ech ">>>> build_crc32c"
    local third_party_path="${WORKSPACE_CURRENT}/src/third_party"
    local CRC32C_PATH="${third_party_path}/crc32c/src"
    cd "${CRC32C_PATH}" || exit
    mkdir -p build && cd build || exit
    cmake .. -G Xcode \
        -DCMAKE_SYSTEM_NAME=iOS \
        -DCMAKE_TOOLCHAIN_FILE="${WORKSPACE_CURRENT}/cmake/ios.toolchain.cmake" \
        -DCRC32C_BUILD_TESTS=0 \
        -DCRC32C_BUILD_BENCHMARKS=0 \
        -DCMAKE_ANDROID_STL_TYPE=c++_static \
        -DCRC32C_USE_GLOG=0 \
        -DENABLE_BITCODE=FALSE \
        -DCMAKE_INSTALL_PREFIX="$(pwd)/install/${ARCH}"

    make clean
    cmake --build . --config Release
    make all install
    cd "${WORKSPACE_CURRENT}" || exit
}
function setting_pkg() {
    echo "pkgconfig=$(which pkgconfig)"
    echo "pkgconfig=$(whereis pkgconfig)"
    local third_party_path="${WORKSPACE_CURRENT}/src/third_party"
    local X264_PATH="${third_party_path}/x264/${ARCH}"
    local FDK_AAC_PATH="${third_party_path}/fdk-aac/${ARCH}"
    local OPUS_PATH="${third_party_path}/opus/${ARCH}"
    local OPENSSL_PATH="${third_party_path}/openssl/${ARCH}"
    local FFMPEG_PATH="${third_party_path}/ffmpeg/${ARCH}"

    # Concatenate paths step by step
    PKG_CONFIG_PATH="$X264_PATH/lib/pkgconfig"
    PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$FDK_AAC_PATH/lib/pkgconfig"
    PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$OPUS_PATH/lib/pkgconfig"
    PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$OPENSSL_PATH/lib/pkgconfig"
    PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$FFMPEG_PATH/lib/pkgconfig"

    # Export the final PKG_CONFIG_PATH
    export PKG_CONFIG_PATH
    echo "PKG_CONFIG_PATH = ${PKG_CONFIG_PATH}"
}
function build_okrtc(){
    # setting_pkg

mkdir -p build && cd build || exit
echo "tttttt WORKSPACE_CURRENT = $(pwd)"
cmake .. -G Xcode \
        -DCMAKE_TOOLCHAIN_FILE=../cmake/ios.toolchain.cmake \
        -DOK_RTC_BUILD_AUDIO_BACKENDS=OFF \
        -DOK_RTC_USE_PIPEWIRE=OFF \
        -DPLATFORM=OS64 \
        -DENABLE_BITCODE=FALSE \
        -DCMAKE_INSTALL_PREFIX="$(pwd)/install/${ARCH}"
make clean

cmake --build . --config Release
make install
 cd "${WORKSPACE_CURRENT}" || exit
}
 build_okrtc
# build_crc32c
