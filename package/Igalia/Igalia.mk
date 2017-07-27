SUB_MAKEFILES := $(sort $(wildcard package/Igalia/*/*.mk))

include $(SUB_MAKEFILES)
