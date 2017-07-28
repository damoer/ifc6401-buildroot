CHROMIUM_VERSION = ac0ab56
CHROMIUM_SOURCE = chromium-wayland-$(CHROMIUM_VERSION).tar.xz
CHROMIUM_SITE = https://tmp.igalia.com/chromium-tarballs

CHROMIUM_DEPENDENCIES = host-ninja host-depottools

CHROMIUM_BUILD_TYPE = 'Release'

GN_CONFIG = " \
        gold_path=\"\" \
        enable_nacl=false \
        is_clang=false \
        fatal_linker_warnings=false \
        v8_use_external_startup_data=false \
        linux_use_bundled_binutils=false \
        use_gold=true \
        is_component_build=false \
        proprietary_codecs=false \
        use_ozone=true \
        ozone_auto_platforms=false \
        ozone_platform_headless=true \
        enable_package_mash_services=true \
        ozone_platform_wayland=true \
        ozone_platform_x11=false \
        ozone_platform=\"wayland\" \
        v8_use_snapshot=false \
        use_kerberos=false \
        use_cups=false \
        use_gnome_keyring=false \
        treat_warnings_as_errors=false \
        target_cpu=\"${CPUTARGET}\" \
        target_os=\"linux\" \
        host_toolchain=\"//build/toolchain/cros:host\" \
        custom_toolchain=\"//build/toolchain/cros:target\" \
        v8_snapshot_toolchain=\"//build/toolchain/cros:v8_snapshot\" \
        cros_host_is_clang=false \
        cros_target_ar=\"${AR}\" \
        cros_target_cc=\"${CC}\" \
        cros_target_cxx=\"${CXX}\" \
        cros_target_ld=\"${CXX}\" \
        cros_target_extra_cflags=\"${CFLAGS}\" \
        cros_target_extra_ldflags=\"${TARGET_LDFLAGS}\" \
        cros_target_extra_cxxflags=\"${CXXFLAGS}\" \
        cros_target_extra_cppflags=\"${TARGET_CPPFLAGS}\" \
        cros_v8_snapshot_ar=\"${BUILD_AR}\" \
        cros_v8_snapshot_cc=\"${BUILD_CPP}\" \
        cros_v8_snapshot_cxx=\"${BUILD_CXX}\" \
        cros_v8_snapshot_ld=\"${BUILD_CXX}\" \
        cros_v8_snapshot_extra_cflags=\"${BUILD_CFLAGS}\" \
        cros_v8_snapshot_extra_cxxflags=\"${BUILD_CXXFLAGS}\" \
        cros_v8_snapshot_extra_cppflags=\"${BUILD_CPPFLAGS}\" \
        cros_v8_snapshot_extra_ldflags=\"${BUILD_LDFLAGS}\" \
        cros_host_cc=\"${BUILD_CC}\" \
        cros_host_cxx=\"${BUILD_CXX}\" \
        cros_host_ar=\"${BUILD_AR}\" \
        cros_host_ld=\"${BUILD_CXX}\" \
        cros_host_extra_cflags=\"${BUILD_CFLAGS}\" \
        cros_host_extra_cxxflags=\"${BUILD_CXXFLAGS}\" \
        cros_host_extra_cppflags=\"${BUILD_CPPFLAGS}\" \
        cros_host_extra_ldflags=\"${BUILD_LDFLAGS}\" \
        target_sysroot=\"${STAGING_DIR_TARGET}\" \
        is_official_build=true \
        is_debug=false \
"

define CHROMIUM_CONFIGURE_CMDS

        (cd $(@D); \
            PYTHON=$(HOST_DIR)/usr/bin/python2 $(HOST_DIR)/usr/bin/python2 \
                tools/gn/bootstrap/bootstrap.py --gn-gen-args ${GN_CONFIG} && \
                out/$(CHROMIUM_BUILD_TYPE)/gn gen out/$(CHROMIUM_BUILD_TYPE) --args=${GN_CONFIG} \
        )

endef

define CHROMIUM_BUILD_CMDS

        (cd $(@D); \
            ninja -v -C out/${CHROMIUM_BUILD_TYPE} chrome chrome_sandbox mash:all \
        )

endef

$(eval $(generic-package))
