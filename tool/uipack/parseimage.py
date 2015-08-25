#_*_ coding:utf-8 _*_

import os
import sys
import json
from string import Template
from pathutil import *

__all__ = [
    "packimage",
    "png2ppm",
    "parsejson",
    "imagefind",
    "imagewh",
    "imagerange",
    "imagescale9"
]

def CMD(cmd):
    print (cmd)
    assert os.system(cmd)==0

def packimage(inpath, outname):
    print "[+]"+inpath
    fpng  = outname+"{n1}.png" # "{n}.png"
    fjson = outname+"{n1}.json" # "{n}.json"
    
    CMD(' '.join([
        'TexturePacker',
        '--algorithm MaxRects',
        '--maxrects-heuristics Best',
        '--pack-mode Best',
        #'--scale %s'%args.scale,
        '--premultiply-alpha',
        '--sheet '+fpng,
        '--texture-format png',
        '--extrude 2',
        '--data '+fjson,
        '--format json',
        '--trim-mode Trim',
        #'--trim-mode None',
        '--disable-rotation',
        '--size-constraints AnySize',
        '--max-width 2048',
        '--max-height 2048',
        '--multipack',
        #'--common-division-x 2',
        #'--common-division-y 2',
        #'--shape-debug',
        os.path.join(inpath, "*.png"),
        ]))
    print "[=]"+fpng
    print "[=]"+fjson

def png2ppm(fpng, outdir):
    print "[+]"+fpng
    name = os.path.splitext(os.path.split(fpng)[-1])[0]
    name, n = splitnumber(name)
    if n: n = "."+n
    fppm  = os.path.join(outdir, "%s%s.ppm"%(name,n))
    fpgm  = os.path.join(outdir, "%s%s.pgm"%(name,n))

    CMD("convert %s %s"%(fpng, fppm))
    CMD("convert %s -channel A -separate %s"%(fpng,fpgm))
    print "[=]"+fppm
    print "[=]"+fpgm

#########################################################

def RANGE(v):
    return (v["x"], v["y"], v["w"], v["h"])

def parsejson(fjson, startid):
    print "[+]"+fjson
    name, _ = os.path.splitext(fjson)
    name, n = splitnumber(name)
    tex = int(n)
    imgid = startid

    f = open(fjson)
    j = json.load(f)
    l = list()
    for k, v in j["frames"].items():
        d = dict()
        d["id"] = imgid
        d["export"] = k
        d["src"] = RANGE(v["frame"])
        d["screen"] = RANGE(v["spriteSourceSize"])
        d['size'] = (v['sourceSize']['w'], v['sourceSize']['h'])
        d["tex"] = tex
        l.append(d)
        imgid += 1
    return l

def imagefind(img_l, name):
    for v in img_l:
        if v["export"] == name:
            return v
    assert False, "Cannot found image:"+name

def imagerange(pic):
    #screen = pic['screen']
    #return screen[0]*2 + screen[2], screen[1]*2 + screen[3] # 包括边缘的留白
    size = pic['size']
    return size[0], size[1]

def imagewh(pic):
    screen = pic['screen']
    return screen[2], screen[3] # 不包括边缘的留白

def imagescale9(img, c, startid):
    l = list()
    for i in range(9):
        d = dict()
        d['id'] = startid+i
        d['export'] = img['export']+'_s9_'+str(i)
        d['tex'] = img['tex']
        l.append(d) 

    sx,sy,sw,sh = c['scale9x'],c['scale9y'],c['scale9w'],c['scale9h']
    padx = img['screen'][0]
    pady = img['screen'][1]
    x,y,w,h = img['src'][0],img['src'][1],img['size'][0],img['size'][1]
    l[0]['src'] = (x            ,y              ,sx-padx        ,sy-pady)
    l[1]['src'] = (x+sx-padx    ,y              ,sw             ,sy-pady)
    l[2]['src'] = (x+sx-padx+sw ,y              ,w-sx-sw        ,sy-pady)
    l[3]['src'] = (x            ,y+sy-pady      ,sx-padx        ,sh)
    l[4]['src'] = (x+sx-padx    ,y+sy-pady      ,sw             ,sh)
    l[5]['src'] = (x+sx-padx+sw ,y+sy-pady      ,w-sx-sw        ,sh)
    l[6]['src'] = (x            ,y+sy-pady+sh   ,sx-padx        ,h-sy-sh)
    l[7]['src'] = (x+sx-padx    ,y+sy-pady+sh   ,sw             ,h-sy-sh)
    l[8]['src'] = (x+sx-padx+sw ,y+sy-pady+sh   ,w-sx-sw        ,h-sy-sh)
   
    #x,y,w,h = img['screen'][0],img['screen'][1],img['size'][0],img['size'][1]
    #l[0]['screen'] = (x            ,y              ,sx-padx        ,sy-pady)
    #l[1]['screen'] = (x+sx-padx    ,y              ,sw             ,sy-pady)
    #l[2]['screen'] = (x+sx-padx+sw ,y              ,w-sx-sw        ,sy-pady)
    #l[3]['screen'] = (x            ,y+sy-pady      ,sx-padx        ,sh)
    #l[4]['screen'] = (x+sx-padx    ,y+sy-pady      ,sw             ,sh)
    #l[5]['screen'] = (x+sx-padx+sw ,y+sy-pady      ,w-sx-sw        ,sh)
    #l[6]['screen'] = (x            ,y+sy-pady+sh   ,sx-padx        ,h-sy-sh)
    #l[7]['screen'] = (x+sx-padx    ,y+sy-pady+sh   ,sw             ,h-sy-sh)
    #l[8]['screen'] = (x+sx-padx+sw ,y+sy-pady+sh   ,w-sx-sw        ,h-sy-sh)
    
    x,y,w,h = img['screen'][0],img['screen'][1],img['screen'][2],img['screen'][3]
    l[0]['screen'] = (x,y,sx-padx        ,sy-pady)
    l[1]['screen'] = (0,y,sw             ,sy-pady)
    l[2]['screen'] = (0,y,w+padx-sx-sw   ,sy-pady)
    l[3]['screen'] = (x,0,sx-padx        ,sh)
    l[4]['screen'] = (0,0,sw             ,sh)
    l[5]['screen'] = (0,0,w+padx-sx-sw   ,sh)
    l[6]['screen'] = (x,0,sx-padx        ,h+pady-sy-sh)
    l[7]['screen'] = (0,0,sw             ,h+pady-sy-sh)
    l[8]['screen'] = (0,0,w+padx-sx-sw   ,h+pady-sy-sh)
    return l
