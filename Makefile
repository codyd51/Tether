ARCHS = armv7 arm64
TARGET = iphone:clang:latest:latest
THEOS_BUILD_DIR = Packages
GO_EASY_ON_ME=1

include theos/makefiles/common.mk

TWEAK_NAME = Tether
Tether_FILES = Tweak.xm
Tether_FILES += DGTController.mm
Tether_FILES += DGTConcentricRingView.mm
Tether_FILES += DGTFloatingTimeView.mm
Tether_FILES += BEMAnalogClockView.m
Tether_FILES += KSMHand.m
Tether_FILES += UIAlertView+Blocks.m
Tether_FRAMEWORKS = UIKit
Tether_FRAMEWORKS += CoreGraphics
Tether_FRAMEWORKS += QuartzCore
Tether_FRAMEWORKS += EventKit
Tether_FRAMEWORKS += AudioToolbox
Tether_PRIVATE_FRAMEWORKS = AudioToolbox
Tether_CFLAGS = -fobjc-arc
Tether_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
