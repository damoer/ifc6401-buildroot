################################################################################
#
# WPEWebKit
#
################################################################################

WPEWEBKIT_VERSION = 2.17.92.4
WPEWEBKIT_SITE = http://people.igalia.com/aperez/files/wpe
WPEWEBKIT_SOURCE = wpewebkit-$(WPEWEBKIT_VERSION).tar.xz

WPEWEBKIT_INSTALL_STAGING = YES

WPEWEBKIT_BUILD_WEBKIT=y
WPEWEBKIT_BUILD_JSC=n
WPEWEBKIT_USE_PORT=WPE
ifeq ($(BR2_PACKAGE_WPEWEBKIT_JSC),y)
WPEWEBKIT_BUILD_JSC=y
ifeq ($(BR2_PACKAGE_WPEWEBKIT_ONLY_JSC),y)
WPEWEBKIT_BUILD_WEBKIT=n
WPEWEBKIT_USE_PORT=JSCOnly
endif
endif

WPEWEBKIT_DEPENDENCIES = host-bison host-cmake host-flex host-gperf host-ruby icu pcre

ifeq ($(WPEWEBKIT_BUILD_WEBKIT),y)
WPEWEBKIT_DEPENDENCIES += wpebackend libgcrypt libgles libegl cairo freetype fontconfig \
	harfbuzz libxml2 libxslt sqlite libsoup jpeg libpng libepoxy
endif

WPEWEBKIT_EXTRA_FLAGS = -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

ifeq ($(BR2_PACKAGE_NINJA),y)
WPEWEBKIT_DEPENDENCIES += host-ninja
WPEWEBKIT_EXTRA_FLAGS += \
	-G Ninja
ifeq ($(VERBOSE),1)
WPEWEBKIT_EXTRA_OPTIONS += -v
endif
endif

ifeq ($(BR2_TOOLCHAIN_USES_UCLIBC),y)
WPEWEBKIT_EXTRA_FLAGS += \
	-D__UCLIBC__=ON
endif

ifeq ($(BR2_PACKAGE_LIBINPUT),y)
WPEWEBKIT_DEPENDENCIES += libinput
endif

ifeq ($(WPEWEBKIT_BUILD_WEBKIT),y)
WPEWEBKIT_FLAGS = \
	-DEXPORT_DEPRECATED_WEBKIT2_C_API=ON \
	-DENABLE_ACCELERATED_2D_CANVAS=ON \
	-DENABLE_GEOLOCATION=OFF \
	-DENABLE_DEVICE_ORIENTATION=ON \
	-DENABLE_GAMEPAD=ON \
	-DENABLE_SUBTLE_CRYPTO=ON \
	-DENABLE_FULLSCREEN_API=OFF \
	-DENABLE_NOTIFICATIONS=ON \
	-DENABLE_DATABASE_PROCESS=ON \
	-DENABLE_INDEXED_DATABASE=ON \
	-DENABLE_FETCH_API=ON

ifeq ($(BR2_TOOLCHAIN_USES_MUSL),y)
WPEWEBKIT_FLAGS += -DENABLE_SAMPLING_PROFILER=OFF
else
WPEWEBKIT_FLAGS += -DENABLE_SAMPLING_PROFILER=ON
endif

ifeq ($(BR2_PACKAGE_WEBP),y)
WPEWEBKIT_DEPENDENCIES += webp
endif

ifeq ($(BR2_PACKAGE_WPEWEBKIT_ENABLE_NATIVE_VIDEO),y)
WPEWEBKIT_FLAGS += -DENABLE_NATIVE_VIDEO=ON
else
WPEWEBKIT_FLAGS += -DENABLE_NATIVE_VIDEO=OFF
endif

ifeq ($(BR2_PACKAGE_WPEWEBKIT_ENABLE_NATIVE_AUDIO),y)
WPEWEBKIT_FLAGS += -DENABLE_NATIVE_AUDIO=ON
else
WPEWEBKIT_FLAGS += -DENABLE_NATIVE_AUDIO=OFF
endif

ifeq ($(BR2_PACKAGE_WPEWEBKIT_ENABLE_TEXT_SINK),y)
WPEWEBKIT_FLAGS += -DENABLE_TEXT_SINK=ON
else
WPEWEBKIT_FLAGS += -DENABLE_TEXT_SINK=OFF
endif

ifeq ($(BR2_PACKAGE_GSTREAMER1),y)
WPEWEBKIT_DEPENDENCIES += gstreamer1 gst1-plugins-base gst1-plugins-good gst1-plugins-bad
WPEWEBKIT_FLAGS += \
	-DENABLE_VIDEO=ON \
	-DENABLE_VIDEO_TRACK=ON
else
WPEWEBKIT_FLAGS += \
	-DENABLE_VIDEO=OFF \
	-DENABLE_VIDEO_TRACK=OFF
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_DORNE),y)
WPEWEBKIT_FLAGS += -DENABLE_WEB_AUDIO=OFF
else
ifeq ($(BR2_PACKAGE_WPEWEBKIT_USE_WEB_AUDIO),y)
WPEWEBKIT_FLAGS += -DENABLE_WEB_AUDIO=ON
else
WPEWEBKIT_FLAGS += -DENABLE_WEB_AUDIO=OFF
endif
endif

ifeq ($(BR2_PACKAGE_WPEWEBKIT_ENABLE_MEDIA_SOURCE),y)
WPEWEBKIT_FLAGS += -DENABLE_MEDIA_SOURCE=ON
else
WPEWEBKIT_FLAGS += -DENABLE_MEDIA_SOURCE=OFF
endif

ifeq ($(BR2_PACKAGE_WPEWEBKIT_USE_ENCRYPTED_MEDIA_V1),y)
WPEWEBKIT_FLAGS += -DENABLE_LEGACY_ENCRYPTED_MEDIA_V1=ON
endif
ifeq ($(BR2_PACKAGE_WPEWEBKIT_USE_ENCRYPTED_MEDIA_V2),y)
WPEWEBKIT_FLAGS += -DENABLE_LEGACY_ENCRYPTED_MEDIA=ON
endif
ifeq ($(BR2_PACKAGE_WPEWEBKIT_USE_ENCRYPTED_MEDIA_V3),y)
WPEWEBKIT_FLAGS += -DENABLE_ENCRYPTED_MEDIA=ON
endif

ifeq ($(BR2_PACKAGE_WPEWEBKIT_USE_PLAYREADY),y)
WPEWEBKIT_DEPENDENCIES += playready
WPEWEBKIT_FLAGS += -DENABLE_PLAYREADY=ON
endif

ifeq ($(BR2_PACKAGE_WPEWEBKIT_USE_OPENCDM),y)
WPEWEBKIT_DEPENDENCIES += opencdm
WPEWEBKIT_FLAGS += -DENABLE_OPENCDM=ON
endif

ifeq ($(BR2_PACKAGE_WPEWEBKIT_ENABLE_MEDIA_STREAM),y)
WPEWEBKIT_DEPENDENCIES += openwebrtc
WPEWEBKIT_FLAGS += -DENABLE_MEDIA_STREAM=ON
endif

ifeq ($(BR2_PACKAGE_WPEWEBKIT_USE_GSTREAMER_GL),y)
WPEWEBKIT_FLAGS += -DUSE_GSTREAMER_GL=ON
endif

ifeq ($(BR2_PACKAGE_WPEWEBKIT_USE_GSTREAMER_WEBKIT_HTTP_SRC),y)
WPEWEBKIT_FLAGS += -DUSE_GSTREAMER_WEBKIT_HTTP_SRC=ON
else
WPEWEBKIT_FLAGS += -DUSE_GSTREAMER_WEBKIT_HTTP_SRC=OFF
endif

ifeq ($(BR2_PACKAGE_WPEWEBKIT_USE_FUSION_API),y)
WPEWEBKIT_FLAGS += -DUSE_FUSION_SINK=ON
endif

ifeq ($(BR2_PACKAGE_WPEWEBKIT_USE_PUNCH_HOLE_GSTREAMER),y)
WPEWEBKIT_FLAGS += -DUSE_HOLE_PUNCH_GSTREAMER=ON
else ifeq ($(BR2_PACKAGE_WPEWEBKIT_USE_PUNCH_HOLE_EXTERNAL),y)
WPEWEBKIT_FLAGS += -DUSE_HOLE_PUNCH_EXTERNAL=ON
endif

endif

ifeq ($(BR2_PACKAGE_WESTEROS),y)
WPEWEBKIT_FLAGS += -DUSE_WPEWEBKIT_PLATFORM_WESTEROS=ON -DUSE_HOLE_PUNCH_GSTREAMER=OFF
else ifeq ($(BR2_PACKAGE_HAS_NEXUS),y)
WPEWEBKIT_FLAGS += -DUSE_WPEWEBKIT_PLATFORM_BCM_NEXUS=ON
else ifeq ($(BR2_PACKAGE_HORIZON_SDK),y)
WPEWEBKIT_FLAGS += -DUSE_WPEWEBKIT_PLATFORM_INTEL_CE=ON
else ifeq ($(BR2_PACKAGE_INTELCE_SDK),y)
WPEWEBKIT_FLAGS += -DUSE_WPEWEBKIT_PLATFORM_INTEL_CE=ON
endif

ifeq ($(BR2_PACKAGE_WPEWEBKIT_ONLY_JSC), y)
WPEWEBKIT_FLAGS += -DENABLE_STATIC_JSC=ON
endif

WPEWEBKIT_EXTRA_FLAGS += -DCMAKE_CXX_FLAGS="-DMESA_EGL_NO_X11_HEADERS"

WPEWEBKIT_CONF_OPTS = \
	-DPORT=$(WPEWEBKIT_USE_PORT) \
	$(WPEWEBKIT_EXTRA_FLAGS) \
	$(WPEWEBKIT_FLAGS)

WPEWEBKIT_BUILDDIR = $(@D)/build-$(if $(BR2_ENABLE_DEBUG),Debug,Release)

ifeq ($(BR2_PACKAGE_NINJA),y)

WPEWEBKIT_BUILD_TARGETS=
ifeq ($(WPEWEBKIT_BUILD_JSC),y)
WPEWEBKIT_BUILD_TARGETS += jsc
endif
ifeq ($(WPEWEBKIT_BUILD_WEBKIT),y)
WPEWEBKIT_BUILD_TARGETS += libWPEWebKit.so libWPEWebInspectorResources.so \
	WPE{Database,Network,Web}Process

endif

define WPEWEBKIT_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/ninja -C $(WPEWEBKIT_BUILDDIR) $(WPEWEBKIT_EXTRA_OPTIONS) $(WPEWEBKIT_BUILD_TARGETS)
endef

ifeq ($(WPEWEBKIT_BUILD_JSC),y)
define WPEWEBKIT_INSTALL_STAGING_CMDS_JSC
	pushd $(WPEWEBKIT_BUILDDIR) && \
	cp bin/jsc $(STAGING_DIR)/usr/bin/ && \
	popd > /dev/null
endef
else
WPEWEBKIT_INSTALL_STAGING_CMDS_JSC = true
endif

ifeq ($(WPEWEBKIT_BUILD_WEBKIT),y)
define WPEWEBKIT_INSTALL_STAGING_CMDS_WEBKIT
	cp $(WPEWEBKIT_BUILDDIR)/bin/WPE{Database,Network,Web}Process $(STAGING_DIR)/usr/bin/ && \
	cp -d $(WPEWEBKIT_BUILDDIR)/lib/libWPE* $(STAGING_DIR)/usr/lib/ && \
	DESTDIR=$(STAGING_DIR) $(HOST_DIR)/usr/bin/cmake -DCOMPONENT=Development -P $(WPEWEBKIT_BUILDDIR)/Source/JavaScriptCore/cmake_install.cmake > /dev/null && \
	DESTDIR=$(STAGING_DIR) $(HOST_DIR)/usr/bin/cmake -DCOMPONENT=Development -P $(WPEWEBKIT_BUILDDIR)/Source/WebKit2/cmake_install.cmake > /dev/null
endef
else
WPEWEBKIT_INSTALL_STAGING_CMDS_WEBKIT = true
endif

define WPEWEBKIT_INSTALL_STAGING_CMDS
	($(WPEWEBKIT_INSTALL_STAGING_CMDS_JSC) && \
	$(WPEWEBKIT_INSTALL_STAGING_CMDS_WEBKIT))
endef

ifeq ($(WPEWEBKIT_BUILD_JSC),y)
define WPEWEBKIT_INSTALL_TARGET_CMDS_JSC
	cp $(WPEWEBKIT_BUILDDIR)/bin/jsc $(TARGET_DIR)/usr/bin/ && \
	$(STRIPCMD) $(TARGET_DIR)/usr/bin/jsc
endef
else
WPEWEBKIT_INSTALL_TARGET_CMDS_JSC = true
endif

ifeq ($(WPEWEBKIT_BUILD_WEBKIT),y)
define WPEWEBKIT_INSTALL_TARGET_CMDS_WEBKIT
	cp $(WPEWEBKIT_BUILDDIR)/bin/WPE{Database,Network,Web}Process $(TARGET_DIR)/usr/bin/ && \
	cp -d $(WPEWEBKIT_BUILDDIR)/lib/libWPE* $(TARGET_DIR)/usr/lib/ && \
	$(STRIPCMD) $(TARGET_DIR)/usr/lib/libWPEWebKit.so.0.0.*
endef
else
WPEWEBKIT_INSTALL_TARGET_CMDS_WEBKIT = true
endif

define WPEWEBKIT_INSTALL_TARGET_CMDS
	($(WPEWEBKIT_INSTALL_TARGET_CMDS_JSC) && \
	$(WPEWEBKIT_INSTALL_TARGET_CMDS_WEBKIT))
endef

endif

RSYNC_VCS_EXCLUSIONS += --exclude LayoutTests --exclude WebKitBuild

$(eval $(cmake-package))
