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
--ar=llvm-ar --ranlib=llvm-ranlib --enable-pic --disable-asm \
--extra-cflags="-I$prefix_dir/include $cpuflags" --extra-ldflags="-L$prefix_dir/lib" \
--disable-static --enable-shared --enable-gpl --enable-version3 \
--disable-stripping --disable-doc --disable-programs \

# ===== 基础禁用（保留截图所需的滤镜和封装） =====
--disable-muxers --enable-muxer=image2 \
--disable-encoders --enable-encoder=mjpeg,png \
--disable-filters --enable-filter=format,scale \
--disable-devices --disable-bsfs \
--disable-v4l2-m2m \
--enable-swscale \

# ===== 核心黑名单：精准打击冷门格式 =====

# 1. 视频黑名单
--disable-decoder=prores,svq3,cinepak,indeo2,indeo3,vc1,wmv1,wmv2,wmv3 \
--disable-decoder=rv10,rv20,rv30,rv40,h261,h263,h263i,h263p \
--disable-decoder=flv1,msmpeg4v1,msmpeg4v2,msmpeg4v3,vp3,vp5,vp6 \
--disable-decoder=aic,dirac,utvideo,dnxhd,cfhd,ccube \
--disable-decoder=camstudio,cscd,loco,qtrle,roqvideo,tscc,tscc2,vmnc,zmbv \
--disable-decoder=asv1,asv2,cllc,8bps,kgv1,mimic,msrle,msvideo1,pictor \
--disable-decoder=eamad,eatgq,eatgv,eatqi,tqi,vble \

# 2. 音频黑名单
--disable-decoder=adpcm_4xm,adpcm_adx,adpcm_ct,adpcm_ea,adpcm_g722,adpcm_g726,adpcm_g726le \
--disable-decoder=adpcm_ima_amv,adpcm_ima_apc,adpcm_ima_dk3,adpcm_ima_dk4,adpcm_ima_ea_sead,adpcm_ima_ea_eacs \
--disable-decoder=adpcm_ima_iss,adpcm_ima_qt,adpcm_ima_smjpeg,adpcm_ima_wav,adpcm_ima_ws,adpcm_ms \
--disable-decoder=adpcm_sbpro_2,adpcm_sbpro_3,adpcm_sbpro_4,adpcm_swf,adpcm_yamaha,adpcm_zork \
--disable-decoder=g723_1,g726,g729,gsm,ilbc,qcelp,voxware,truespeech,lpc,speex \
--disable-decoder=bonk,binkaudio_dct,binkaudio_rdft,nellymoser,twinvq,sipr,roq_dpcm,xan_dpcm,ws_snd1 \

# 3. 解析器黑名单
--disable-parser=vc1,rv10,rv20,rv30,rv40,h261,h263,dirac,g729,speex \

# 4. 解封装黑名单
--disable-demuxer=rm,avs,4xm,aa,act,adf,aea,bethsoftvid,bfi,bink,c93,cdg,cine \
--disable-demuxer=daf,dsicin,dss,dtshd,dxa,ea,film_cpk,g722,g726,g729,gsm,iff,ilbc,iv8,jv,lmlm4 \
--disable-demuxer=loas,mm,mtv,mvi,nc,nut,nuv,paf,pva,qcp,r3d,rl2,roq,rpl,rsd,sami,smacker,smjpeg \
--disable-demuxer=sol,subviewer,thp,tta,txd,vag,viv,vmd,voc,vqf,w64,wc3,yop \

# ===== 保持现代格式和硬解全开 =====
--enable-jni --enable-mediacodec --enable-mbedtls --enable-libdav1d --enable-libxml2 --disable-vulkan

make -j$cores
make DESTDIR="$prefix_dir" install
