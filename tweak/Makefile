TARGET = iphone:clang:11.4:10.0
INSTALL_TARGET_PROCESSES = tv.danmaku.bilianime

ARCHS = armv7 armv7s arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LegacyBiliProxy

LegacyBiliProxy_FILES = Tweak.xm
LegacyBiliProxy_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

