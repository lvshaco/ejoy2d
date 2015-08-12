import os
import sys
from pathutil import *
from parseimage import *
from parsecsd import *
from combine import *
from optparse import OptionParser

if __name__ == "__main__":
    usage = "usage: %prog [options] imgdir csddir outdir"
    parser = OptionParser(usage=usage)
    parser.add_option("-i", "--packimage", 
            action="store_true", 
            default=False, 
            dest="bpackimage", 
            help="pack image") 
    parser.add_option("-c", "--parsecsd", 
            action="store_true", 
            default=False, 
            dest="bparsecsd", 
            help="parser csd")
    (options, argv) = parser.parse_args()
    if len(argv) != 3:
        parser.error("incorrect args")
        sys.exit(1)
    imgdir = argv[0]
    csddir = argv[1]
    outdir = argv[2]
    packname = getdirbase(imgdir)
    tmpdir = '__tmp_'+packname

    if not os.path.isdir(outdir):
        os.mkdir(outdir)
    if options.bpackimage: 
        #if os.path.isdir(tmpdir):
            #rmdirs(tmpdir) 
        
        # pack texture dir
        outname = os.path.join(tmpdir, packname)
        packimage(imgdir, outname)

        # all png to ppm
        files = list()
        getfiles(tmpdir, [".png"], 1, files)
        for f in files:
            png2ppm(f, outdir)

    if options.bparsecsd:
        # parse json
        img_l = list()
        files = list()
        getfiles(tmpdir, [".json"], 1, files)
        for f in files:
            img_l += parsejson(f, len(img_l))
        startid = len(img_l)
        # parse csd
        csd_l = list()
        files = list()
        getfiles(csddir, [".csd"], 1, files)
        for f in files:
            c = parsecsd(f, startid)
            csd_l.append(c)
            startid += len(c) 
        combine(csd_l, img_l, outdir, packname) 
