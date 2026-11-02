export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = KeepAwakePrefs

KeepAwakePrefs_FILES = KAKRootListController.m
KeepAwakePrefs_INSTALL_PATH = /Library/PreferenceBundles
KeepAwakePrefs_FRAMEWORKS = UIKit
KeepAwakePrefs_PRIVATE_FRAMEWORKS = Preferences
KeepAwakePrefs_CFLAGS = -fobjc-arc
KeepAwakePrefs_LDFLAGS = -Wl,-segalign,4000

include $(THEOS)/makefiles/bundle.mk

# Install the PreferenceLoader entry so the pane shows up in Settings.
internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/KeepAwake.plist$(ECHO_END)
