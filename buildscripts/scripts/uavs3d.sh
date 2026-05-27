#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

build=_build$ndk_suffix

if [ "$1" == "build" ]; then
        true
elif [ "$1" == "clean" ]; then
        rm -rf $build
        exit 0
else
        exit 255
fi

mkdir -p $build
cd $build

# Determine ANDROID_ABI from ndk_triple
if [ "$ndk_triple" == "arm-linux-androideabi" ]; then
        android_abi=armeabi-v7a
elif [ "$ndk_triple" == "aarch64-linux-android" ]; then
        android_abi=arm64-v8a
elif [ "$ndk_triple" == "i686-linux-android" ]; then
        android_abi=x86
elif [ "$ndk_triple" == "x86_64-linux-android" ]; then
        android_abi=x86_64
fi

ndk_path=$(echo "$DIR/sdk/android-sdk-linux/ndk/$v_ndk")

cmake -S .. \
        -DCMAKE_INSTALL_PREFIX="$prefix_dir" \
        -DANDROID_NDK="$ndk_path" \
        -DANDROID_ABI="$android_abi" \
        -DCMAKE_TOOLCHAIN_FILE="$ndk_path/build/cmake/android.toolchain.cmake" \
        -DANDROID_PLATFORM=android-26 \
        -DANDROID_STL=c++_static \
        -DCMAKE_BUILD_TYPE=Release \
        -DCOMPILE_10BIT=1 \
        -DBUILD_SHARED_LIBS=0

cmake --build . --target uavs3d --config Release
cmake --install . --strip

# Fix uavs3d.pc - remove -lpthread which doesn't exist on Android
pcfile="$prefix_dir/lib/pkgconfig/uavs3d.pc"
if [ -f "$pcfile" ]; then
        sed -i 's/-lpthread//' "$pcfile"
fi
