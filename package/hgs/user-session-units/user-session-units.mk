################################################################################
#
# user-session-units
#
################################################################################

USER_SESSION_UNITS_VERSION = 152bbce0ab9193139c9998ff9c5def3f096f0550
USER_SESSION_UNITS_SITE  = $(call github,sofar,user-session-units,$(USER_SESSION_UNITS_VERSION))
USER_SESSION_UNITS_LICENSE = GPLv2
USER_SESSION_UNITS_LICENSE_FILES = COPYING

USER_SESSION_UNITS_AUTORECONF = YES

USER_SESSION_UNITS_DEPENDENCIES = systemd linux-pam
USER_SESSION_UNITS_MAKE = $(MAKE1)

$(eval $(autotools-package))
