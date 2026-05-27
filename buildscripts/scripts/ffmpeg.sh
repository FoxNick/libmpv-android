#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
        true
elif [ "$1" == "clean" ]; then
        rm -rf _build$ndk_suffix
        exit 0
else
        exit 255
fi

mkdir -p _build$ndk_suffix
cd _build$ndk_suffix

cpu=armv7-a
[[ "$ndk_triple" == "aarch64"* ]] && cpu=armv8-a
[[ "$ndk_triple" == "x86_64"* ]] && cpu=generic
[[ "$ndk_triple" == "i686"* ]] && cpu="i686 --disable-asm"

cpuflags=
asmflags=
[[ "$ndk_triple" == "arm"* ]] && cpuflags="$cpuflags -mfpu=neon -mcpu=cortex-a8"
# Enable neon/asm/inline-asm for ARM architectures (armv7a, arm64)
if [[ "$ndk_triple" == "arm"* || "$ndk_triple" == "aarch64"* ]]; then
        asmflags="--enable-neon --enable-asm --enable-inline-asm"
        # Add -DPIC for proper PIC support in NEON assembly on AArch64
        cpuflags="$cpuflags -DPIC"
else
        asmflags="--disable-neon --disable-asm --disable-inline-asm"
fi

../configure \
 --target-os=android --enable-cross-compile --cross-prefix=$ndk_triple- --cc=$CC \
 --arch=${ndk_triple%%-*} --cpu=$cpu --pkg-config=pkg-config --nm=llvm-nm \
 --ar=llvm-ar --ranlib=llvm-ranlib --enable-pic $asmflags \
 --extra-cflags="-I$prefix_dir/include $cpuflags" --extra-ldflags="-L$prefix_dir/lib" \
 --enable-{jni,mediacodec,mbedtls,libdav1d,libxml2} --disable-vulkan \
 --enable-static --disable-shared --enable-{gpl,version3} \
 --disable-{stripping,doc,programs} \
 --disable-{muxers,encoders,devices,filters} \
 --disable-v4l2-m2m
 
make -j$cores
make DESTDIR="$prefix_dir" install
