LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := lpng
#LOCAL_ARM_MODE  := arm
#LOCAL_CFLAGS 	:= -DHAVE_CONFIG_H

LOCAL_C_INCLUDES:= \
	$(LOCAL_PATH)/../../3rd/lpng/libpng \
	$(LOCAL_PATH)/../../lua

LOCAL_SRC_FILES = \
../../3rd/lpng/lpng.c
../../3rd/lpng/libpng/png.c \
../../3rd/lpng/libpng/pngerror.c \
../../3rd/lpng/libpng/pngget.c \
../../3rd/lpng/libpng/pngmem.c \
../../3rd/lpng/libpng/pngpread.c \
../../3rd/lpng/libpng/pngread.c \
../../3rd/lpng/libpng/pngrio.c \
../../3rd/lpng/libpng/pngrtran.c \
../../3rd/lpng/libpng/pngrutil.c \
../../3rd/lpng/libpng/pngset.c \
../../3rd/lpng/libpng/pngtrans.c \
../../3rd/lpng/libpng/pngwio.c \
../../3rd/lpng/libpng/pngwrite.c \
../../3rd/lpng/libpng/pngwtran.c \
../../3rd/lpng/libpng/pngwutil.c

include $(BUILD_STATIC_LIBRARY)
