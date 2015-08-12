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
        d["tex"] = tex
        l.append(d)
        imgid += 1
    return l
