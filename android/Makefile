.PHONY : default update build pack install dist clean cleanall dump

path=$(shell pwd)
wl=$(subst /, ,$(path))
wn=$(shell echo $$(($(words $(wl))-2)))
name=$(word $(wn),$(wl))

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

create:
	lua create.lua $(name)

update:
	$(ANDROID) update project -p . -n $(name) --target android-16
build:
	ndk-build NDK_BUILD=1 NDK_MODULE_PATH=$(path)
pack:
	rm -rf assets/files/*
	mkdir -pv assets
	cp -r ../ejoy2d assets/files
	cp -r ../util assets/files
	cp ../../*.lua assets/files
	cp -r ../../asset assets/files
	ant debug
install:
	adb uninstall com.lvshaco.$(name)
	adb install bin/$(name)-debug.apk

dist: update build pack install

clean:
	rm -rf bin gen 
cleanall: clean
	ndk-build clean NDK_MODULE_PATH=$(path)
	rm -f AndroidManifest.xml
	rm -f build.xml proguard-project.txt local.properties
	rm -f .dump.log
	rm -rf assets

dump:
	echo "*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***" > .dump.log
	adb logcat -d -s DEBUG >> .dump.log
	ndk-stack -sym obj/local/armeabi -dump .dump.log
	rm -f .dump.log
