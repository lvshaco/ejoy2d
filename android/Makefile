.PHONY : default update build pack install dist all clean cleanall dump tojava tonative

name=jack

default: dist

UNAME=$(shell uname)
SYS=$(if $(filter CYGWIN%,$(UNAME)),cygwin,\
	        undefined\
)
ifeq ($(SYS),cygwin)
	ANDROID="android.bat"
else
	ANDROID="android"
endif

update:
	$(ANDROID) update project -p . -n $(name) --target android-16
build:
	ndk-build NDK_BUILD=1 NDK_MODULE_PATH=`pwd`
pack:
	rm -rf assets/files/*
	mkdir -pv assets
	cp -r ../ejoy2d assets/files
	cp -r ../util assets/files
	cp -r ../$(name) assets/files
	ant debug
install:
	adb uninstall com.example.$(name)
	adb install bin/$(name)-debug.apk

dist: build pack install
all: update dist

clean:
	rm -rf bin gen 
cleanall: clean
	rm -rf libs obj
	rm -f build.xml proguard-project.txt

dump:
	echo "*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***" > .dump.log
	adb logcat -d -s DEBUG >> .dump.log
	ndk-stack -sym obj/local/armeabi -dump .dump.log
	rm -f .dump.log

tojava: cleanall
	cp AndroidManifest.xml.java AndroidManifest.xml
	cp jni/Android.mk.java jni/Android.mk

tonative: cleanall
	cp AndroidManifest.xml.native AndroidManifest.xml
	cp jni/Android.mk.native jni/Android.mk
