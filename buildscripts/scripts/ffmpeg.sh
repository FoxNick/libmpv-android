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
# Apply HLS PNG disguise fix patch if not already applied
PATCH_DIR="$(dirname "$0")/../"
PATCH_FILE="${PATCH_DIR}ffmpeg-hls-png-fix.patch"
if [ -f "$PATCH_FILE" ]; then
        if ! grep -q "HLS_PNG_FIX" libavformat/hls.c 2>/dev/null; then
                echo "Applying HLS PNG disguise fix patch..."
                patch -p1 --no-backup-if-mismatch -i "$PATCH_FILE" || {
                        echo "Warning: HLS PNG fix patch failed to apply, continuing without it"
                }
        else
                echo "HLS PNG disguise fix patch already applied, skipping"
        fi
else
        echo "Warning: HLS PNG fix patch not found at $PATCH_FILE"
fi
mkdir -p _build$ndk_suffix
cd _build$ndk_suffix

cpu=armv7-a
[[ "$ndk_triple" == "aarch64"* ]] && cpu=armv8-a
[[ "$ndk_triple" == "x86_64"* ]] && cpu=generic
[[ "$ndk_triple" == "i686"* ]] && cpu="i686 --disable-asm"

cpuflags=
[[ "$ndk_triple" == "arm"* ]] && cpuflags="$cpuflags -mfpu=neon -mcpu=cortex-a8"

../configure \
        --target-os=android --enable-cross-compile --cross-prefix=$ndk_triple- --cc=$CC \
        --arch=${ndk_triple%%-*} --cpu=$cpu --pkg-config=pkg-config --nm=llvm-nm \
        --ar=llvm-ar --ranlib=llvm-ranlib --enable-pic --disable-asm \
        --extra-cflags="-I$prefix_dir/include $cpuflags" --extra-ldflags="-L$prefix_dir/lib" \
        --enable-{jni,mediacodec,mbedtls,libdav1d,libxml2} --disable-vulkan \
        --enable-static --disable-shared --enable-{gpl,version3} \
        --disable-{stripping,doc,programs} \
        --disable-{muxers,encoders,devices,filters} \
        --disable-v4l2-m2m

make -j$cores
make DESTDIR="$prefix_dir" install
