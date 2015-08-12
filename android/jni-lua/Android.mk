LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := lua
#LOCAL_ARM_MODE  := arm
LOCAL_CFLAGS 	:= -D"l_getlocaledecpoint()='.'" -D LUA_COMPAT_APIINTCASTS

LOCAL_SRC_FILES = \
../../lua/lapi.c \
../../lua/lauxlib.c \
../../lua/lbaselib.c \
../../lua/lbitlib.c \
../../lua/lcode.c \
../../lua/lcorolib.c \
../../lua/lctype.c \
../../lua/ldblib.c \
../../lua/ldebug.c \
../../lua/ldo.c \
../../lua/ldump.c \
../../lua/lfunc.c \
../../lua/lgc.c \
../../lua/linit.c \
../../lua/liolib.c \
../../lua/llex.c \
../../lua/lmathlib.c \
../../lua/lmem.c \
../../lua/loadlib.c \
../../lua/lobject.c \
../../lua/lopcodes.c \
../../lua/loslib.c \
../../lua/lparser.c \
../../lua/lstate.c \
../../lua/lstring.c \
../../lua/lstrlib.c \
../../lua/ltable.c \
../../lua/ltablib.c \
../../lua/ltm.c \
../../lua/lundump.c \
../../lua/lutf8lib.c \
../../lua/lvm.c \
../../lua/lzio.c \
../../lua/srcpack.c
include $(BUILD_STATIC_LIBRARY)
