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
[[ "$ndk_triple" == "arm"* ]] && cpuflags="$cpuflags -mfpu=neon -mcpu=cortex-a8"

../configure \
        --target-os=android --enable-cross-compile --cross-prefix=$ndk_triple- --cc=$CC \
        --arch=${ndk_triple%%-*} --cpu=$cpu --pkg-config=pkg-config --nm=llvm-nm \
        --ar=llvm-ar --ranlib=llvm-ranlib --enable-pic --enable-asm --enable-neon \
        --extra-cflags="-I$prefix_dir/include $cpuflags -fpic -DPIC" --extra-ldflags="-L$prefix_dir/lib" \
        --enable-{jni,mediacodec,mbedtls,libdav1d,libxml2} --disable-vulkan \
        --enable-static --disable-shared --enable-{gpl,version3} \
        --disable-{stripping,doc,programs,debug} \
        --disable-{muxers,encoders,devices,filters,bsfs} \
        --disable-v4l2-m2m \
        --disable-decoders \
        --enable-decoder=h264,hevc,vp8,vp9,av1,vvc,mpeg4,mpeg2video,mpeg1video,msmpeg4v3 \
        --enable-decoder=rv10,rv20,rv30,rv40,prores,bink \
        --enable-decoder=cook,sipr,wmapro,wmav1,wmav2 \
        --enable-decoder=aac,aac_latm,ac3,eac3,dca,flac,mp3,opus,vorbis \
        --enable-decoder=pcm_s16le,pcm_s24le,pcm_s32le,pcm_f32le,pcm_dvd \
        --enable-decoder=ape,alac,amrnb,amrwb,qdm2 \
        --enable-decoder=ass,subrip,hdr \
        --enable-decoder=h264_mediacodec,hevc_mediacodec,vp9_mediacodec,av1_mediacodec,mpeg4_mediacodec,vvc_mediacodec \
        --enable-muxer=mov,matroska,mpegts,image2 \
        --enable-encoder=mjpeg,png \
        --disable-demuxers \
        --enable-demuxer=mov,matroska,mpegts,mpegps,flv,avi,ogg,wav,rawvideo,hls,dash,ape,ac3,eac3,mp3 \
        --disable-parsers \
        --enable-parser=h264,hevc,vp9,av1,aac,aac_latm,ac3,eac3,dca,flac,mpeg4video,opus,vorbis,mpegaudio \
        --disable-protocols \
        --enable-protocol=file,http,https,crypto,hls,rtmp,rtmps,rtsp,concat,pipe


make -j$cores
make DESTDIR="$prefix_dir" install
