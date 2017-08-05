CHROMIUM_VERSION = ac0ab56
CHROMIUM_SOURCE = chromium-wayland-$(CHROMIUM_VERSION).tar.xz
CHROMIUM_SITE = https://tmp.igalia.com/chromium-tarballs

CHROMIUM_DEPENDENCIES = host-ninja host-depottools libnss dbus wayland libegl \
			libglib2 freetype alsa-lib pciutils fontconfig pulseaudio

CHROMIUM_BUILD_TYPE = 'Release'

GN_CONFIG_COMMON = \
	gold_path="" \
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
	ozone_platform="wayland" \
	v8_use_snapshot=false \
	use_kerberos=false \
	use_cups=false \
	use_gnome_keyring=false \
	treat_warnings_as_errors=false \
	target_os="linux" \
	is_official_build=true \
	use_sysroot=false \
	is_debug=false

GN_CONFIG_CROSS = $(GN_CONFIG_COMMON) \
	target_cpu=$(BR2_ARCH) \
	host_toolchain="//build/toolchain/cros:host" \
	custom_toolchain="//build/toolchain/cros:target" \
	v8_snapshot_toolchain="//build/toolchain/cros:v8_snapshot" \
	cros_host_is_clang=false \
	cros_target_ar="$(TARGET_AR)" \
	cros_target_cc="$(TARGET_CC)" \
	cros_target_cxx="$(TARGET_CXX)" \
	cros_target_ld="$(TARGET_CXX)" \
	cros_target_extra_cflags="$(TARGET_CFLAGS)" \
	cros_target_extra_ldflags="$(TARGET_LDFLAGS)" \
	cros_target_extra_cxxflags="$(TARGET_CXXFLAGS)" \
	cros_target_extra_cppflags="$(TARGET_CPPFLAGS)" \
	cros_v8_snapshot_ar="$(HOSTAR)" \
	cros_v8_snapshot_cc="$(HOSTCPP)" \
	cros_v8_snapshot_cxx="$(HOSTCXX)" \
	cros_v8_snapshot_ld="$(HOSTCXX)" \
	cros_v8_snapshot_extra_cflags="$(TARGET_CFLAGS)" \
	cros_v8_snapshot_extra_cxxflags="$(TARGET_CXXFLAGS)" \
	cros_v8_snapshot_extra_cppflags="$(TARGET_CPPFLAGS)" \
	cros_v8_snapshot_extra_ldflags="$(TARGET_LDFLAGS)" \
	cros_host_cc="$(HOSTCC)" \
	cros_host_cxx="$(HOSTCXX)" \
	cros_host_ar="$(HOSTAR)" \
	cros_host_ld="$(HOSTCXX)" \
	cros_host_extra_cflags="$(HOSTCFLAGS)" \
	cros_host_extra_cxxflags="$(HOSTCXXFLAGS)" \
	cros_host_extra_cppflags="$(HOSTCPPFLAGS)" \
	cros_host_extra_ldflags="$(HOSTLDFLAGS)" \
	target_sysroot="$(STAGING_DIR)"


define CHROMIUM_FIXUP_PYTHON_SCRIPTS
        find '$(@D)' -name '*.py' -exec sed -i -r 's|/usr/bin/python$$|$(HOST_DIR)/usr/bin/python2|g' {} +
endef

define CHROMIUM_CREATE_LOCAL_PYTHON_SYMLINK
        mkdir -p '$(@D)/python2-path'
        ln -sf '$(HOST_DIR)/usr/bin/python2' '$(@D)/python2-path/python'
endef

CHROMIUM_POST_PATCH_HOOKS += CHROMIUM_FIXUP_PYTHON_SCRIPTS CHROMIUM_CREATE_LOCAL_PYTHON_SYMLINK

CHROMIUM_EXTRA_ENV = \
        PYTHON='$(HOST_DIR)/usr/bin/python2' \
        PATH="$(@D)/python2-path:$${PATH}"

define CHROMIUM_CONFIGURE_CMDS
        cd '$(@D)' && $(CHROMIUM_EXTRA_ENV) python tools/gn/bootstrap/bootstrap.py \
                --gn-gen-args '$(GN_CONFIG_COMMON)'
        cd '$(@D)' && $(CHROMIUM_EXTRA_ENV) out/$(CHROMIUM_BUILD_TYPE)/gn \
                gen out/$(CHROMIUM_BUILD_TYPE) \
                --args='$(GN_CONFIG_CROSS)' \
                --script-executable='$(HOST_DIR)/usr/bin/python2'
endef

define CHROMIUM_BUILD_CMDS
        cd '$(@D)' && $(CHROMIUM_EXTRA_ENV) ninja -C out/$(CHROMIUM_BUILD_TYPE) chrome chrome_sandbox mash:all
endef

define CHROMIUM_INSTALL_TARGET_CMDS
        mkdir -p $(TARGET_DIR)/usr/lib/chromium/ && \
        cp -av $(@D)/out/$(CHROMIUM_BUILD_TYPE)/chrome $(TARGET_DIR)/usr/lib/chromium/chromium && \
        chmod 755 $(TARGET_DIR)/usr/lib/chromium/chromium && \
        cp -av $(@D)/out/$(CHROMIUM_BUILD_TYPE)/chrome_sandbox $(TARGET_DIR)/usr/lib/chromium/chrome-sandbox && \
        chmod 4755 $(TARGET_DIR)/usr/lib/chromium/chrome-sandbox && \
        cp -av $(@D)/out/$(CHROMIUM_BUILD_TYPE)/chrome $(TARGET_DIR)/usr/lib/chromium/chromedriver && \
        chmod 755 $(TARGET_DIR)/usr/lib/chromium/chromedriver && \
        ln -svf $(TARGET_DIR)/usr/lib/chromium/chromium $(TARGET_DIR)/usr/bin && \
        ln -svf $(TARGET_DIR)/usr/lib/chromium/chromedriver $(TARGET_DIR)/usr/bin/ && \
        cp -av $(@D)/out/$(CHROMIUM_BUILD_TYPE)/icudtl.dat $(TARGET_DIR)/usr/lib/chromium/ && \
        chmod 644 $(TARGET_DIR)/usr/lib/chromium/icudtl.dat && \
        cp -av $(@D)/out/$(CHROMIUM_BUILD_TYPE)/gen/content/content_resources.pak $(TARGET_DIR)/usr/lib/chromium/ && \
        chmod 644 $(TARGET_DIR)/usr/lib/chromium/content_resources.pak && \
        cp -av $(@D)/out/$(CHROMIUM_BUILD_TYPE)/*.pak $(TARGET_DIR)/usr/lib/chromium/ && \
        chmod 644 $(TARGET_DIR)/usr/lib/chromium/*.pak && \
        cp -av $(@D)/out/$(CHROMIUM_BUILD_TYPE)/locales $(TARGET_DIR)/usr/lib/chromium/
endef

$(eval $(generic-package))
