import os
import sys
from string import Template
from pathutil import *
from parseimage import *

SCREEN_SCALE = 16

PICTURE = """
{
    type = "picture",
    id = $id,
    $export
    { tex = $tex, src = {$src}, screen = {$screen} },
},"""

def _range(v, scale):
    x,y,w,h=v
    if scale != 1:
        x,y,w,h = x*scale, y*scale, w*scale, h*scale
    return "%d,%d,%d,%d,%d,%d,%d,%d"%(x,y, x+w,y, x+w,y+h, x,y+h)

def _picture(v):
    v['src'] = _range(v['src'], 1)
    v['screen'] = _range(v['screen'], SCREEN_SCALE)
    return Template(PICTURE).substitute(v)

if __name__ == "__main__":
    usage = "usage: %s imgdir outdir"
    print (sys.argv)
    if len(sys.argv) != 3:
        print (usage%sys.argv[0])
        sys.exit(1)
    imgdir = sys.argv[1]
    outdir = sys.argv[2]
    packname = getdirbase(imgdir)
    tmpdir = '__tmp_'+packname

    # pack texture dir
    outname = os.path.join(tmpdir, packname)
    packimage(imgdir, outname)

    # all png to ppm
    files = list()
    getfiles(tmpdir, [".png"], 1, files)
    for f in files:
        png2ppm(f, outdir)


    img_l = list()
    files = list()
    getfiles(tmpdir, [".json"], 1, files)
    for f in files:
        img_l += parsejson(f, len(img_l))

    t = list()
    t.append('return {')
    for v in img_l:
        if v.get('export'):
            v['export'] = 'export="%s",'%v['export']
        value = _picture(v)
        t.append(value)
    t.append('}')

    flua = os.path.join(outdir, packname+".lua") 
    print "[=]"+flua
    f = open(flua, 'w')
    f.write("".join(t))
    f.close() 
