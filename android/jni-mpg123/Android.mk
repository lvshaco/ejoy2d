LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE    := mpg123

LOCAL_ARM_MODE := arm

LOCAL_CFLAGS := -g -O2 -Wall \
	-D__ANDROID__ \
	-DACCURATE_ROUNDING \
	-DOPT_ARM \
	-DREAL_IS_FIXED \
	-DNO_REAL \
	-DNO_32BIT

MPG123_DIR = $(LOCAL_PATH)/../../3rd/laudio/dep/mpg123-android

LOCAL_C_INCLUDES:= \
	$(MPG123_DIR) \
	$(MPG123_DIR)/libmpg123

LOCAL_SRC_FILES := \
	$(MPG123_DIR)/libmpg123/compat.c \
	$(MPG123_DIR)/libmpg123/frame.c \
	$(MPG123_DIR)/libmpg123/id3.c \
	$(MPG123_DIR)/libmpg123/format.c \
	$(MPG123_DIR)/libmpg123/stringbuf.c \
	$(MPG123_DIR)/libmpg123/libmpg123.c\
	$(MPG123_DIR)/libmpg123/readers.c\
	$(MPG123_DIR)/libmpg123/icy.c\
	$(MPG123_DIR)/libmpg123/icy2utf8.c\
	$(MPG123_DIR)/libmpg123/index.c\
	$(MPG123_DIR)/libmpg123/layer1.c\
	$(MPG123_DIR)/libmpg123/layer2.c\
	$(MPG123_DIR)/libmpg123/layer3.c\
	$(MPG123_DIR)/libmpg123/parse.c\
	$(MPG123_DIR)/libmpg123/optimize.c\
	$(MPG123_DIR)/libmpg123/synth.c\
	$(MPG123_DIR)/libmpg123/synth_8bit.c\
	$(MPG123_DIR)/libmpg123/synth_arm.S\
	$(MPG123_DIR)/libmpg123/ntom.c\
	$(MPG123_DIR)/libmpg123/dct64.c\
	$(MPG123_DIR)/libmpg123/equalizer.c\
	$(MPG123_DIR)/libmpg123/dither.c\
	$(MPG123_DIR)/libmpg123/tabinit.c\
	$(MPG123_DIR)/libmpg123/synth_arm_accurate.S\
	$(MPG123_DIR)/libmpg123/feature.c

include $(BUILD_STATIC_LIBRARY)
