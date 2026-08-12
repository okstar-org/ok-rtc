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

# libjpeg-turbo 是 v6b API（见上面 WITH_JPEG7/WITH_JPEG8 OFF 的注释）。若它的
# jpeg_* 符号被导出到进程全局符号表，会与 Qt6 libqjpeg.so 链接的系统 libjpeg.so.8
# （v8）发生符号插桩冲突——两者 jpeg_decompress_struct 布局不同，Qt 一解码 JPEG
# （QImage::fromData）就段错误。隐藏符号后它们只对 libOkRTC.so 内部（libyuv）可见，
# 不再泄漏到全局。同 DSO 内的引用不受影响。
set_target_properties(jpeg-static PROPERTIES C_VISIBILITY_PRESET hidden)

# jpeg-static does not expose any include directories by itself, so add them
# here:
#   ${libjpeg_loc}/src      - jpeglib.h / jmorecfg.h / jerror.h
#   ${libjpeg_binary_dir}   - generated jconfig.h (configure_file)
target_include_directories(jpeg-static
PUBLIC
    $<BUILD_INTERFACE:${libjpeg_loc}/src>
    $<BUILD_INTERFACE:${libjpeg_binary_dir}>
)
