cmake_minimum_required(VERSION 3.22.1)

project("libmpv")

add_library(
        player
        SHARED
        main.cpp render.cpp log.cpp jni_utils.cpp property.cpp event.cpp
)

# Static library path from buildscripts/prefix/${ANDROID_ABI}/lib
set(PREFIX_LIB "${CMAKE_CURRENT_SOURCE_DIR}/../../../../buildscripts/prefix/${ANDROID_ABI}/lib")
set(PREFIX_INC "${CMAKE_CURRENT_SOURCE_DIR}/../../../../buildscripts/prefix/${ANDROID_ABI}/include")

include_directories(${PREFIX_INC})

# Import all static libraries
# mpv
add_library(mpv STATIC IMPORTED)
set_target_properties(mpv PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libmpv.a)

# FFmpeg
add_library(avcodec STATIC IMPORTED)
set_target_properties(avcodec PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libavcodec.a)

add_library(avformat STATIC IMPORTED)
set_target_properties(avformat PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libavformat.a)

add_library(avutil STATIC IMPORTED)
set_target_properties(avutil PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libavutil.a)

add_library(swresample STATIC IMPORTED)
set_target_properties(swresample PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libswresample.a)

add_library(swscale STATIC IMPORTED)
set_target_properties(swscale PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libswscale.a)

add_library(avfilter STATIC IMPORTED)
set_target_properties(avfilter PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libavfilter.a)

add_library(avdevice STATIC IMPORTED)
set_target_properties(avdevice PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libavdevice.a)

# dav1d
add_library(dav1d STATIC IMPORTED)
set_target_properties(dav1d PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libdav1d.a)

# uavs3d
add_library(uavs3d STATIC IMPORTED)
set_target_properties(uavs3d PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libuavs3d.a)

# mbedtls
add_library(mbedtls STATIC IMPORTED)
set_target_properties(mbedtls PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libmbedtls.a)

add_library(mbedx509 STATIC IMPORTED)
set_target_properties(mbedx509 PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libmbedx509.a)

add_library(mbedcrypto STATIC IMPORTED)
set_target_properties(mbedcrypto PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libmbedcrypto.a)

# libxml2
add_library(xml2 STATIC IMPORTED)
set_target_properties(xml2 PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libxml2.a)

# libass
add_library(ass STATIC IMPORTED)
set_target_properties(ass PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libass.a)

# freetype
add_library(freetype STATIC IMPORTED)
set_target_properties(freetype PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libfreetype.a)

# fontconfig
add_library(fontconfig STATIC IMPORTED)
set_target_properties(fontconfig PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libfontconfig.a)

# fribidi
add_library(fribidi STATIC IMPORTED)
set_target_properties(fribidi PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libfribidi.a)

# harfbuzz (multiple sub-libraries)
add_library(harfbuzz STATIC IMPORTED)
set_target_properties(harfbuzz PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libharfbuzz.a)

add_library(harfbuzz-subset STATIC IMPORTED)
set_target_properties(harfbuzz-subset PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libharfbuzz-subset.a)

add_library(harfbuzz-gpu STATIC IMPORTED)
set_target_properties(harfbuzz-gpu PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libharfbuzz-gpu.a)

add_library(harfbuzz-raster STATIC IMPORTED)
set_target_properties(harfbuzz-raster PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libharfbuzz-raster.a)

add_library(harfbuzz-vector STATIC IMPORTED)
set_target_properties(harfbuzz-vector PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libharfbuzz-vector.a)

# libunibreak
add_library(unibreak STATIC IMPORTED)
set_target_properties(unibreak PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libunibreak.a)

# lua
add_library(lua STATIC IMPORTED)
set_target_properties(lua PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/liblua.a)

# libplacebo
add_library(placebo STATIC IMPORTED)
set_target_properties(placebo PROPERTIES IMPORTED_LOCATION ${PREFIX_LIB}/libplacebo.a)

# Link everything statically into libplayer.so
# Order matters for static linking - dependencies must come after dependents
target_link_libraries(player
        mpv
        avformat avcodec avfilter swresample swscale avutil avdevice
        ass freetype fontconfig fribidi
        harfbuzz harfbuzz-subset harfbuzz-gpu harfbuzz-raster harfbuzz-vector
        unibreak
        lua placebo
        dav1d uavs3d xml2 mbedtls mbedx509 mbedcrypto
        log android mediandk z m dl vulkan
        EGL OpenSLES
)
