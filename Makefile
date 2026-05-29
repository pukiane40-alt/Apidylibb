ARCHS = arm64
TARGET = iphone:clang:16.5:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ZombiMod

ZombiMod_FILES = Tweak.x ZMLicenseManager.m ZMMenuController.m ZMFloatingButton.m
ZombiMod_CFLAGS = -fobjc-arc -Wno-unused-variable -Wno-deprecated-declarations
ZombiMod_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
ZombiMod_PRIVATE_FRAMEWORKS =
ZombiMod_LIBRARIES =

export BUNDLE_FILTER = com.dts.freefireth

include $(THEOS)/makefiles/tweak.mk
