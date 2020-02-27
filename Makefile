ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = colorABle
colorABle_FILES = Tweak.xm $(wildcard ./*.m)
colorABle_CFLAGS += -fobjc-arc
colorABle_LDFLAGS += -lCSColorPicker
#colorABle_LIBRARIES = colorpicker


include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 AlienBlue"
SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
