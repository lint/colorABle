ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = colorABlePrefs

colorABlePrefs_FILES = CABRootListController.m
colorABlePrefs_INSTALL_PATH = /Library/PreferenceBundles
colorABlePrefs_FRAMEWORKS = UIKit
colorABlePrefs_PRIVATE_FRAMEWORKS = Preferences
#prefe_LIBRARIES = colorpicker
colorABlePrefs_LDFLAGS += -lCSColorPicker
colorABlePrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/colorABlePrefs.plist$(ECHO_END)
