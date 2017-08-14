################################################################################
#
# WPEBackend
#
################################################################################

WPEBACKEND_MESA_VERSION = 926e52e94836cb9b7559ca6cb6550e61fcd117d6
WPEBACKEND_MESA_SITE = $(call github,WebPlatformForEmbedded,WPEBackend-mesa,$(WPEBACKEND_MESA_VERSION))
WPEBACKEND_MESA_INSTALL_STAGING = YES
WPEBACKEND_MESA_DEPENDENCIES = wpebackend libglib2

WPEBACKEND_MESA_FLAGS = 

WPEBACKEND_MESA_FLAGS += -DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) -DMESA_EGL_NO_X11_HEADERS"

WPEBACKEND_MESA_CONF_OPTS = \
	$(WPEBACKEND_MESA_FLAGS)

$(eval $(cmake-package))
