LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE    := openal
#LOCAL_SRC_FILES = $(LOCAL_PATH)/../../3rd/laudio/prebuild/android/$(TARGET_ARCH_ABI)/libopenal.k
#LOCAL_SRC_FILES = ../../3rd/laudio/prebuild/android/armeabi/libopenal.a
#LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../../3rd/laudio/prebuild/include
OPENAL_DIR = $(LOCAL_PATH)/../../3rd/laudio/dep/openal-soft-android

LOCAL_CFLAGS += \
	-DAL_ALEXT_PROTOTYPES \
	-DANDROID \
	-fpic \
	-ffunction-sections \
	-funwind-tables \
	-fstack-protector \
	-fno-short-enums \
	-DHAVE_GCC_VISIBILITY \
	-O3 \
	-g


LOCAL_C_INCLUDES:= \
	$(OPENAL_DIR) \
	$(OPENAL_DIR)/include \
	$(OPENAL_DIR)/OpenAL32/Include

LOCAL_SRC_FILES :=  \
	$(OPENAL_DIR)/Alc/android.c              \
	$(OPENAL_DIR)/OpenAL32/alAuxEffectSlot.c \
	$(OPENAL_DIR)/OpenAL32/alBuffer.c        \
	$(OPENAL_DIR)/OpenAL32/alDatabuffer.c    \
	$(OPENAL_DIR)/OpenAL32/alEffect.c        \
	$(OPENAL_DIR)/OpenAL32/alError.c         \
	$(OPENAL_DIR)/OpenAL32/alExtension.c     \
	$(OPENAL_DIR)/OpenAL32/alFilter.c        \
	$(OPENAL_DIR)/OpenAL32/alListener.c      \
	$(OPENAL_DIR)/OpenAL32/alSource.c        \
	$(OPENAL_DIR)/OpenAL32/alState.c         \
	$(OPENAL_DIR)/OpenAL32/alThunk.c         \
	$(OPENAL_DIR)/Alc/ALc.c                  \
	$(OPENAL_DIR)/Alc/alcConfig.c            \
	$(OPENAL_DIR)/Alc/alcEcho.c              \
	$(OPENAL_DIR)/Alc/alcModulator.c         \
	$(OPENAL_DIR)/Alc/alcReverb.c            \
	$(OPENAL_DIR)/Alc/alcRing.c              \
	$(OPENAL_DIR)/Alc/alcThread.c            \
	$(OPENAL_DIR)/Alc/ALu.c                  \
	$(OPENAL_DIR)/Alc/bs2b.c                 \
	$(OPENAL_DIR)/Alc/null.c                 \
	$(OPENAL_DIR)/Alc/panning.c              \
	$(OPENAL_DIR)/Alc/mixer.c                \
	$(OPENAL_DIR)/Alc/audiotrack.c           \

include $(BUILD_STATIC_LIBRARY)
