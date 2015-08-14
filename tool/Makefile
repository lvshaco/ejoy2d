.PHONY: packcsd packimage uipack ui join clean

#python run.py -i jack -x
	#cp output/jack.lua output/jack.1.ppm output/jack.1.pgm ~/ejoy2d/jack/asset

path=$(shell pwd)
wl=$(subst /, ,$(path))
wn=$(shell echo $$(($(words $(wl))-2)))
name=$(word $(wn),$(wl))

ifeq ($(name),)
	target=undefined
else
	target=ui
endif

path?=../../..

all: $(target)
undefined:
	@echo "Please do 'make name=your ui name'"

packcsd:
	cd uipack && \
	python uipack.py -c \
		$(path)/ui/cocosstudio/image \
		$(path)/ui/cocosstudio/ \
		$(path)/asset

packimage:
	cd uipack && \
	python uipack.py -i \
		$(path)/ui/cocosstudio/image \
		$(path)/ui/cocosstudio/ \
		$(path)/asset

flash:
	cd flash-parser && \
	python run.py -i $(path)/flash -o $(path)/asset

join:
	cd uipack && \
	lua uijoin.lua $(path)/asset/ui_$(name).lua \
		$(path)/asset/ui.lua \
		__tmp.lua && \
	rm $(path)/asset/ui.lua && \
	mv __tmp.lua $(path)/asset/ui_$(name).lua && \
	rm $(path)/asset/ui.*.ppm $(path)/asset/ui.*.pgm

uipack: packimage packcsd
ui: packimage packcsd flash join

clean:
	rm -rf uipack/__tmp_uipack
	rm -rf ../$(name)/asset
