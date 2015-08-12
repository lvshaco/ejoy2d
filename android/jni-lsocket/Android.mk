LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := lsocket
#LOCAL_ARM_MODE  := arm
LOCAL_CFLAGS 	:= -DLUA_COMPAT_APIINTCASTS

LOCAL_C_INCLUDES:= $(LOCAL_PATH)/../../3rd/lsocket/src \
				   $(LOCAL_PATH)/../../lua


LOCAL_SRC_FILES = \
	../../3rd/lsocket/src/lsocket.c \
	../../3rd/lsocket/src/lsocketbuffer.c \
	../../3rd/lsocket/src/psocket.c \
	../../3rd/lsocket/src/socket.c

include $(BUILD_STATIC_LIBRARY)
