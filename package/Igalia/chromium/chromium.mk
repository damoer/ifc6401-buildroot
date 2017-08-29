CHROMIUM_VERSION = 65b3572
CHROMIUM_SOURCE = chromium-wayland-$(CHROMIUM_VERSION).tar.xz
CHROMIUM_SITE = https://tmp.igalia.com/chromium-tarballs

CHROMIUM_DEPENDENCIES = host-gn host-ninja libnss dbus wayland libegl \
                        libglib2 freetype alsa-lib pciutils fontconfig \
                        pulseaudio

# Additional (optional) targets passed to Ninja for building.
CHROMIUM_EXTRA_TARGETS =

# Libraries for which the Buildroot packages will be used, instead of the
# versions bundled with the Chromium sources.
CHROMIUM_SYSTEM_LIBS =

ifeq ($(BR2_PACKAGE_CHROMIUM_SYSTEM_ICU),y)
CHROMIUM_SYSTEM_LIBS += icu
CHROMIUM_DEPENDENCIES += icu
else
CHROMIUM_POST_INSTALL_TARGET_HOOKS += CHROMIUM_INSTALL_TARGET_ICU_DATA
endif

# TODO: arm_tune="cortex-a15"
# TODO: arm_use_neon="..."
# TODO: arm_fpu="vfpv4"
# TODO: arm_optionally_use_neon=true
# TODO: use_jumbo_build=true
# TODO: v8_use_snapshot=true

GN_CONFIG = clang_use_chrome_plugins=false \
            enable_nacl=false \
            enable_package_mash_services=true \
            fatal_linker_warnings=false \
            gold_path="" \
            is_clang=false \
            is_component_build=false \
            linux_use_bundled_binutils=false \
            ozone_auto_platforms=false \
            ozone_platform="wayland" \
            ozone_platform_headless=true \
            ozone_platform_wayland=true \
            ozone_platform_x11=false \
            proprietary_codecs=false \
            target_cpu=$(BR2_PACKAGE_CHROMIUM_TARGET_CPU) \
            target_os="linux" \
            target_sysroot="$(STAGING_DIR)" \
            treat_warnings_as_errors=false \
            use_cups=false \
            use_custom_libcxx=false \
            use_debug_fission=false \
            use_gnome_keyring=false \
            use_gold=false \
            use_kerberos=false \
            use_ozone=true \
            v8_target_cpu=$(BR2_PACKAGE_CHROMIUM_TARGET_CPU) \
            v8_use_external_startup_data=false \
            v8_use_snapshot=false

ifeq ($(BR2_USE_CCACHE),y)
GN_CONFIG += cc_wrapper="$(HOST_DIR)/usr/bin/ccache"
endif

ifeq ($(BR2_ENABLE_DEBUG),y)
ifeq ($(BR2_DEBUG_1),y)
GN_CONFIG += symbol_level=1
else
GN_CONFIG += symbol_level=2
endif
CHROMIUM_BUILD_TYPE = Debug
GN_TOOLCHAIN_TARGET_STRIP =
GN_CONFIG += is_debug=true remove_webcore_debug_symbols=false
else
CHROMIUM_BUILD_TYPE = Release
GN_TOOLCHAIN_TARGET_STRIP = strip = "$(TARGET_STRIP)"
GN_CONFIG += is_debug=false remove_webcore_debug_symbols=true
endif

ifneq ($(BR2_ARM_INSTRUCTIONS_THUMB)$(BR2_ARM_INSTRUCTIONS_THUMB2),)
GN_CONFIG += arm_use_thumb=true
endif

ifeq ($(BR2_ARM_EABIHF),y)
GN_CONFIG += arm_float_abi="hard"
endif


define GN_TOOLCHAIN_FILE
import("//build/toolchain/gcc_toolchain.gni")

gcc_toolchain("default") {
  cc = "$(TARGET_CC)"
  cxx = "$(TARGET_CXX)"
  ar = "$(TARGET_AR)"
  nm = "$(TARGET_NM)"
  ld = cxx
  readelf = "$(TARGET_READELF)"
  $(GN_TOOLCHAIN_TARGET_STRIP)

  extra_cflags = "$(TARGET_CFLAGS)"
  extra_cxxflags = "$(TARGET_CXXFLAGS)"
  extra_cppflags = "$(TARGET_CPPFLAGS)"
  extra_ldflags = "$(TARGET_LDFLAGS)"

  toolchain_args = {
    current_cpu = $(BR2_PACKAGE_CHROMIUM_TARGET_CPU)
    current_os = "linux"
    is_clang = false
  }
}

gcc_toolchain("host") {
  cc = "$(HOSTCC_NOCCACHE)"
  cxx = "$(HOSTCXX_NOCCACHE)"
  ar = "$(HOSTAR)"
  nm = "$(HOSTNM)"
  ld = cxx

  extra_cflags = "$(HOST_CFLAGS)"
  extra_cxxflags = "$(HOST_CXXFLAGS)"
  extra_cppflags = "$(HOST_CPPFLAGS)"
  extra_ldflags = "$(HOST_LDFLAGS)"

  toolchain_args = {
    current_cpu = $(BR2_PACKAGE_CHROMIUM_HOST_CPU)
    current_os = "linux"
    use_sysroot = false
    is_clang = false
  }
}
endef

export GN_TOOLCHAIN_FILE

GN_CONFIG += custom_toolchain="//build/toolchain/linux/buildroot:default" \
             host_toolchain="//build/toolchain/linux/buildroot:host" \
             v8_snapshot_toolchain="//build/toolchain/linux/buildroot:host"


define CHROMIUM_FIXUP_PYTHON_SCRIPTS
        find '$(@D)' -name '*.py' -exec sed -i -r 's|/usr/bin/python$$|$(HOST_DIR)/usr/bin/python2|g' {} +
endef

define CHROMIUM_CREATE_LOCAL_PYTHON_SYMLINK
        mkdir -p '$(@D)/python2-path'
        ln -sf '$(HOST_DIR)/usr/bin/python2' '$(@D)/python2-path/python'
endef

define CHROMIUM_CREATE_TEMP_DIR
	mkdir -p '$(@D)/temp'
endef

CHROMIUM_POST_PATCH_HOOKS += CHROMIUM_FIXUP_PYTHON_SCRIPTS \
                             CHROMIUM_CREATE_LOCAL_PYTHON_SYMLINK \
                             CHROMIUM_CREATE_TEMP_DIR


CHROMIUM_EXTRA_ENV = PYTHON='$(HOST_DIR)/usr/bin/python2' \
                     PATH="$(@D)/python2-path:$(HOST_DIR)/usr/bin:$${PATH}" \
                     TMPDIR='$(@D)/temp'


define CHROMIUM_CONFIGURE_CMDS
        mkdir -p '$(@D)/build/toolchain/linux/buildroot'
        echo "$${GN_TOOLCHAIN_FILE}" > '$(@D)/build/toolchain/linux/buildroot/BUILD.gn'
        cd '$(@D)' && $(CHROMIUM_EXTRA_ENV) '$(HOST_DIR)/usr/bin/gn' \
                gen 'out/$(CHROMIUM_BUILD_TYPE)' \
                --args='$(GN_CONFIG)' \
                --script-executable='$(HOST_DIR)/usr/bin/python2'
endef

define CHROMIUM_UNBUNDLE_SYSTEM_LIBS
        cd '$(@D)' && '$(HOST_DIR)/usr/bin/python' \
                build/linux/unbundle/replace_gn_files.py \
                --system-libraries $(CHROMIUM_SYSTEM_LIBS)
endef

ifneq ($(strip $(CHROMIUM_SYSTEM_LIBS)),)
CHROMIUM_PRE_CONFIGURE_HOOKS += CHROMIUM_UNBUNDLE_SYSTEM_LIBS
endif


define CHROMIUM_BUILD_CMDS
        cd '$(@D)' && $(CHROMIUM_EXTRA_ENV) '$(HOST_DIR)/usr/bin/ninja' \
                -C 'out/$(CHROMIUM_BUILD_TYPE)' \
                -j$(PARALLEL_JOBS) \
                chrome chrome_sandbox \
                $(CHROMIUM_EXTRA_TARGETS)
endef

define CHROMIUM_INSTALL_TARGET_CMDS
        install -Dm644 -t '$(TARGET_DIR)/usr/lib/chromium' \
                '$(@D)/out/$(CHROMIUM_BUILD_TYPE)'/*.pak
        install -Dm644 -t '$(TARGET_DIR)/usr/lib/chromium/locales' \
                '$(@D)/out/$(CHROMIUM_BUILD_TYPE)'/locales/*.pak
        install -Dm755 -t '$(TARGET_DIR)/usr/lib/chromium' \
                '$(@D)/out/$(CHROMIUM_BUILD_TYPE)'/*.service
        install -Dm755 '$(@D)/out/$(CHROMIUM_BUILD_TYPE)/chrome' \
                '$(TARGET_DIR)/usr/lib/chromium/chromium'
        install -Dm4755 '$(@D)/out/$(CHROMIUM_BUILD_TYPE)/chrome_sandbox' \
                '$(TARGET_DIR)/usr/lib/chromium/chrome-sandbox'
        ln -sf ../lib/chromium/chromium '$(TARGET_DIR)/usr/bin/chromium'
endef


define CHROMIUM_INSTALL_TARGET_CHROMEDRIVER
        install -Dm755 '$(@D)/out/$(CHROMIUM_BUILD_TYPE)/chromedriver' \
                '$(TARGET_DIR)/usr/lib/chromium/chromedriver'
        ln -sf ../lib/chromium/chromedriver '$(TARGET_DIR)/usr/bin/chromedriver'
endef

ifeq ($(BR2_PACKAGE_CHROMIUM_CHROMEDRIVER),y)
        CHROMIUM_POST_INSTALL_TARGET_HOOKS += CHROMIUM_INSTALL_TARGET_CHROMEDRIVER
        CHROMIUM_EXTRA_TARGETS += chromedriver
endif

define CHROMIUM_INSTALL_TARGET_ICU_DATA
        install -Dm644 -t '$(TARGET_DIR)/usr/lib/chromium' \
                '$(@D)/out/$(CHROMIUM_BUILD_TYPE)/icudtl.dat'
endef


$(eval $(generic-package))
