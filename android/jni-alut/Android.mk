LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE    := alut

LOCAL_CFLAGS := -DHAVE_STDINT_H -DHAVE_STAT -DHAVE_UNISTD_H -DHAVE_USLEEP

ALUT_DIR = $(LOCAL_PATH)/../../3rd/laudio/dep/alut

LOCAL_C_INCLUDES:= \
	$(ALUT_DIR)/include \
	$(ALUT_DIR)/src \
	$(LOCAL_PATH)/../../3rd/laudio/dep/openal-soft-android/include

LOCAL_SRC_FILES :=  \
	$(ALUT_DIR)/src/alutBufferData.c \
	$(ALUT_DIR)/src/alutCodec.c \
	$(ALUT_DIR)/src/alutError.c \
	$(ALUT_DIR)/src/alutInit.c \
	$(ALUT_DIR)/src/alutInputStream.c \
	$(ALUT_DIR)/src/alutLoader.c \
	$(ALUT_DIR)/src/alutOutputStream.c \
	$(ALUT_DIR)/src/alutUtil.c \
	$(ALUT_DIR)/src/alutVersion.c \
	$(ALUT_DIR)/src/alutWaveForm.c

include $(BUILD_STATIC_LIBRARY)
