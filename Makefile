export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = KeepAwake
KeepAwake_FILES = Tweak.x
KeepAwake_CFLAGS = -fobjc-arc
KeepAwake_FRAMEWORKS = UIKit Foundation

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/tweak.mk

SUBPROJECTS += keepawakeprefs
include $(THEOS)/makefiles/aggregate.mk
