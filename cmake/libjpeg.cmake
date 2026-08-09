# libjpeg (libjpeg-turbo)
# Built from the libjpeg-turbo submodule with its own CMake instead of an
# enumerated OBJECT library like libyuv/libsrtp, because libjpeg-turbo carries
# a large amount of per-arch SIMD (NASM) sources. Exposed as ok-rtc::libjpeg.

# Static-only build; skip TurboJPEG API, command-line tools and tests.
# The internal zlib/spng subtree is only pulled in when one of
# WITH_TURBOJPEG / WITH_TOOLS / WITH_TESTS is ON, so disabling them keeps the
# build lean. The standard libjpeg v6b API is kept (WITH_JPEG7/WITH_JPEG8 OFF),
# which is what libyuv's mjpeg_decoder expects.
set(ENABLE_SHARED OFF CACHE BOOL "" FORCE)
set(ENABLE_STATIC ON CACHE BOOL "" FORCE)
set(WITH_TURBOJPEG OFF CACHE BOOL "" FORCE)
set(WITH_TOOLS OFF CACHE BOOL "" FORCE)
set(WITH_TESTS OFF CACHE BOOL "" FORCE)

set(libjpeg_loc ${third_party_loc}/libjpeg-turbo)
set(libjpeg_binary_dir ${CMAKE_CURRENT_BINARY_DIR}/libjpeg-turbo)

add_subdirectory(${libjpeg_loc} ${libjpeg_binary_dir} EXCLUDE_FROM_ALL)

add_library(ok-rtc::libjpeg ALIAS jpeg-static)

# jpeg-static does not expose any include directories by itself, so add them
# here:
#   ${libjpeg_loc}/src      - jpeglib.h / jmorecfg.h / jerror.h
#   ${libjpeg_binary_dir}   - generated jconfig.h (configure_file)
target_include_directories(jpeg-static
PUBLIC
    $<BUILD_INTERFACE:${libjpeg_loc}/src>
    $<BUILD_INTERFACE:${libjpeg_binary_dir}>
)
