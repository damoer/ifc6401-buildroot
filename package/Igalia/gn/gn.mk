GN_VERSION = 20170816.01
GN_SOURCE = gn-$(GN_VERSION).tar.xz
GN_SITE = http://people.igalia.com/aperez/files

HOST_GN_DEPENDENCIES = host-ninja host-python

GN_BUILD_ENV = AR='$(HOSTAR)' \
			   LD='$(HOSTLD)' \
			   CC='$(HOSTCC)' \
			   CXX='$(HOSTCXX)' \
			   LDFLAGS='$(HOSTLDFLAGS)' \
			   CFLAGS='$(HOSTCFLAGS)' \
			   CXXFLAGS='$(HOSTCXXFLAGS)'

define HOST_GN_BUILD_CMDS
cd '$(@D)/tools/gn' && $(GN_BUILD_ENV) $(HOST_DIR)/usr/bin/python2 bootstrap/bootstrap.py -s
endef

define HOST_GN_INSTALL_CMDS
install -m755 -t '$(HOST_DIR)/usr/bin' '$(@D)/out/Release/gn'
endef

$(eval $(host-generic-package))
