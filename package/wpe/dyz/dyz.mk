################################################################################
#
# dyz
#
################################################################################

DYZ_VERSION = ec7a8b93e2c6afb04a7f7feb76d28bfddffaaea0
DYZ_SITE = $(call github,Igalia,dyz,$(DYZ_VERSION))

DYZ_INSTALL_STAGING = YES
DYZ_DEPENDENCIES = luajit

DYZ_MAKE_ENV = \
	$(TARGET_MAKE_ENV) \
	CC=$(TARGET_CC) \
	PKG_CONFIG_PATH="$(TARGET_DIR)/usr/lib/pkgconfig"

$(eval $(autotools-package))
