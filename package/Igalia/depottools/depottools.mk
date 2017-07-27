DEPOTTOOLS_VERSION = 5aa5cd76f00e7774f71367f34d9998cfa0034d04
DEPOTTOOLS_SITE = https://chromium.googlesource.com/chromium/tools/depot_tools.git
DEPOTTOOLS_SITE_METHOD = git

HOST_DEPOTTOOLS_DEPENDENCIES = $(if $(BR2_PACKAGE_PYTHON3),host-python3,host-python)

$(eval $(host-generic-package))
