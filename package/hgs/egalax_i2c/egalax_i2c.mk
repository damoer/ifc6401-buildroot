################################################################################
#
# mbt8xxx
#
################################################################################

EGALAX_I2C_VERSION = 20150423
EGALAX_I2C_SOURCE  = egalax_i2c_allpoint_$(EGALAX_I2C_VERSION)_dt.tar.gz

# do not download tar, it's included in package
EGALAX_I2C_SITE    = $(shell pwd)/package/hgs/egalax_i2c
EGALAX_I2C_SITE_METHOD = file

EGALAX_I2C_DEPENDENCIES = linux

define EGALAX_I2C_BUILD_CMDS
	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D) modules
endef

define EGALAX_I2C_INSTALL_TARGET_CMDS
	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D) modules_install
endef

$(eval $(generic-package))
