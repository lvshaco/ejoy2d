LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := laudio
#LOCAL_ARM_MODE  := arm
LOCAL_CFLAGS 	:= -DLUA_COMPAT_APIINTCASTS

LOCAL_C_INCLUDES:= \
	$(LOCAL_PATH)/../../3rd/laudio/src \
	$(LOCAL_PATH)/../../3rd/laudio/dep/openal-soft-android/include \
	$(LOCAL_PATH)/../../3rd/laudio/dep/alut/include \
	$(LOCAL_PATH)/../../3rd/laudio/dep/mpg123-android \
	$(LOCAL_PATH)/../../lua

LOCAL_SRC_FILES = \
	../../3rd/laudio/src/laudio.c \
	../../3rd/laudio/src/audio_decoder.c

LOCAL_STATIC_LIBRARIES := openal alut  mpg123
include $(BUILD_STATIC_LIBRARY)
$(call import-module,jni-openal)
$(call import-module,jni-alut)
$(call import-module,jni-mpg123)
