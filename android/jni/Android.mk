LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := native-activity

LOCAL_ARM_MODE  := arm

LOCAL_CFLAGS 	:= -D__ANDROID__ 
#LOCAL_CPPFLAGS 	:= -D__ANDROID__ -frtti
LOCAL_LDLIBS 	:= -llog -landroid -lGLESv2 -ldl -lz -Wl,-E

LOCAL_C_INCLUDES:= 	 \
					$(LOCAL_PATH)/../../lua \
					$(LOCAL_PATH)/../../lib \
					$(LOCAL_PATH)/../../lib/render \
					$(LOCAL_PATH)/../../3rd/freetype/include \
					$(LOCAL_PATH)/../../android/jni-javabridge

RENDER := \
	../../lib/render/render.c \
	../../lib/render/carray.c \
	../../lib/render/log.c

EJOY2D := \
	../../lib/shader.c \
	../../lib/lshader.c \
	../../lib/ejoy2dgame.c \
	../../lib/fault.c \
	../../lib/screen.c \
	../../lib/texture.c \
	../../lib/ppm.c \
	../../lib/spritepack.c \
	../../lib/sprite.c \
	../../lib/lsprite.c \
	../../lib/matrix.c \
	../../lib/lmatrix.c \
	../../lib/dfont.c \
	../../lib/label.c \
	../../lib/particle.c \
	../../lib/lparticle.c \
	../../lib/scissor.c \
	../../lib/renderbuffer.c \
	../../lib/lrenderbuffer.c \
	../../lib/lgeometry.c

LOCAL_SRC_FILES := \
	$(RENDER) \
	$(EJOY2D) \
	window-jni.c \
	winfw.c \
	winfont.c \
	myhelper-jni.c \
	../../3rd/lasset/lasset.c \
	../jni-javabridge/jni_helper.c \
	../jni-javabridge/javabridge.c \
	javabridge-jni.c

LOCAL_STATIC_LIBRARIES := lua ft lsocket laudio lpng
include $(BUILD_SHARED_LIBRARY)

$(call import-module,jni-lua)
$(call import-module,jni-ft)
$(call import-module,jni-lsocket)
$(call import-module,jni-laudio)
$(call import-module,jni-lpng)
