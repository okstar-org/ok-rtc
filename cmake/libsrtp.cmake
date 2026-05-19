add_library(libsrtp OBJECT EXCLUDE_FROM_ALL)
init_target(libsrtp)
add_library(ok-rtc::libsrtp ALIAS libsrtp)

if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    # 设置头文件路径
    target_include_directories(ok-rtc PRIVATE
        ${CMAKE_SOURCE_DIR}/third_party/openssl/arm64/include
    )

    # 设置库文件路径
    target_link_directories(ok-rtc PRIVATE
        ${CMAKE_SOURCE_DIR}/third_party/openssl/lib
    )
    target_link_libraries(ok-rtc PRIVATE
        ssl
        crypto
    )
else()
    link_libsrtp(ok-rtc)
endif()

set(libsrtp_loc ${third_party_loc}/libsrtp)

nice_target_sources(libsrtp ${libsrtp_loc}
PRIVATE
    crypto/cipher/aes_gcm_ossl.c
    crypto/cipher/aes_icm_ossl.c
    crypto/cipher/cipher.c
    crypto/cipher/cipher_test_cases.c
    crypto/cipher/null_cipher.c
    crypto/hash/auth.c
    crypto/hash/auth_test_cases.c
    crypto/hash/hmac_ossl.c
    crypto/hash/null_auth.c
    crypto/kernel/alloc.c
    crypto/kernel/crypto_kernel.c
    crypto/kernel/err.c
    crypto/kernel/key.c
    crypto/math/datatypes.c
    crypto/replay/rdb.c
    crypto/replay/rdbx.c
    srtp/srtp.c
)

target_compile_definitions(libsrtp PRIVATE HAVE_CONFIG_H)

if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    target_include_directories(libsrtp
    PRIVATE
        ${third_party_loc}/openssl/arm64/include
    )
else()
endif()
target_include_directories(libsrtp
PUBLIC
    $<BUILD_INTERFACE:${libsrtp_loc}/include>
    $<BUILD_INTERFACE:${libsrtp_loc}/crypto/include>
    $<BUILD_INTERFACE:${libsrtp_loc}/../libsrtp_config>
    $<INSTALL_INTERFACE:${webrtc_includedir}/third_party/libsrtp/include>
    $<INSTALL_INTERFACE:${webrtc_includedir}/third_party/libsrtp/crypto/include>
)
