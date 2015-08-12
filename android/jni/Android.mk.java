LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := native-activity

LOCAL_ARM_MODE  := arm

LOCAL_CFLAGS 	:= -D__ANDROID__ -DFT2_BUILD_LIBRARY -D"getlocaledecpoint()='.'" -frtti
LOCAL_CPPFLAGS 	:= -D__ANDROID__ -DFT2_BUILD_LIBRARY -D"getlocaledecpoint()='.'" -frtti
LOCAL_LDLIBS 	:= -llog -landroid -lGLESv2 -ldl -lz -Wl,-E

LOCAL_C_INCLUDES:= 	 \
					$(LOCAL_PATH)/../../lua \
					$(LOCAL_PATH)/../../lib \
					$(LOCAL_PATH)/../../lib/render \
					$(LOCAL_PATH)/../../3rd/freetype/include \

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
	../../lib/lrenderbuffer.c

LUASRC := \
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
	../../lua/lvm.c \
	../../lua/lzio.c \

FTSRC := \
	../../3rd/freetype/src/base/ftsystem.c \
	../../3rd/freetype/src/base/ftinit.c \
	../../3rd/freetype/src/base/ftdebug.c \
	../../3rd/freetype/src/base/ftbase.c \
	../../3rd/freetype/src/base/ftbbox.c \
	../../3rd/freetype/src/base/ftbdf.c \
	../../3rd/freetype/src/base/ftbitmap.c \
	../../3rd/freetype/src/base/ftcid.c \
	../../3rd/freetype/src/base/ftfstype.c \
	../../3rd/freetype/src/base/ftgasp.c \
	../../3rd/freetype/src/base/ftglyph.c \
	../../3rd/freetype/src/base/ftgxval.c \
	../../3rd/freetype/src/base/ftlcdfil.c \
	../../3rd/freetype/src/base/ftmm.c \
	../../3rd/freetype/src/base/ftotval.c \
	../../3rd/freetype/src/base/ftpatent.c \
	../../3rd/freetype/src/base/ftpfr.c \
	../../3rd/freetype/src/base/ftstroke.c \
	../../3rd/freetype/src/base/ftsynth.c \
	../../3rd/freetype/src/base/fttype1.c \
	../../3rd/freetype/src/base/ftwinfnt.c \
	../../3rd/freetype/src/base/ftxf86.c \
	../../3rd/freetype/src/bdf/bdf.c \
	../../3rd/freetype/src/bzip2/ftbzip2.c \
	../../3rd/freetype/src/cache/ftcache.c \
	../../3rd/freetype/src/cff/cff.c \
	../../3rd/freetype/src/cid/type1cid.c \
	../../3rd/freetype/src/gxvalid/gxvalid.c \
	../../3rd/freetype/src/gzip/ftgzip.c \
	../../3rd/freetype/src/lzw/ftlzw.c \
	../../3rd/freetype/src/otvalid/otvalid.c \
	../../3rd/freetype/src/pcf/pcf.c \
	../../3rd/freetype/src/pfr/pfr.c \
	../../3rd/freetype/src/psaux/psaux.c \
	../../3rd/freetype/src/pshinter/pshinter.c \
	../../3rd/freetype/src/psnames/psnames.c \
	../../3rd/freetype/src/raster/raster.c \
	../../3rd/freetype/src/sfnt/sfnt.c \
	../../3rd/freetype/src/smooth/smooth.c \
	../../3rd/freetype/src/truetype/truetype.c \
	../../3rd/freetype/src/type1/type1.c \
	../../3rd/freetype/src/type42/type42.c \
	../../3rd/freetype/src/winfonts/winfnt.c \
	../../3rd/freetype/src/autofit/autofit.c \

LOCAL_SRC_FILES := \
	$(RENDER) \
	$(EJOY2D) \
	$(LUASRC) \
	$(FTSRC) \
	window-jni.c \
	winfw.c \
	winfont.c \
	lsocket.c

include $(BUILD_SHARED_LIBRARY)

#LOCAL_STATIC_LIBRARIES := android_native_app_glue

#include $(BUILD_SHARED_LIBRARY)

#$(call import-module,android/native_app_glue)
