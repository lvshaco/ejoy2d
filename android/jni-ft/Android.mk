LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := ft
#LOCAL_ARM_MODE  := arm
LOCAL_CFLAGS 	:= -DFT2_BUILD_LIBRARY 

LOCAL_C_INCLUDES:= $(LOCAL_PATH)/../../3rd/freetype/include

LOCAL_SRC_FILES = \
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

include $(BUILD_STATIC_LIBRARY)
