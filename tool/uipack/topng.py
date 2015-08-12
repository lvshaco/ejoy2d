#_*_ coding:utf-8 _*_

from pathutil import *
import sys
import os

def cmd(c):
    print c
    assert os.system(c)==0

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print "usage : %s image(dir) outdir" % sys.argv[0]
        sys.exit(1)
    out = sys.argv[2]
    if not os.path.isdir(out):
        cmd("mkdir %s"%out)
    files = list()
    getfiles(sys.argv[1], [".jpg"], 1, files)
    for f in files:
        b,_ = os.path.splitext(f)
        b = os.path.split(b)[-1]
        b = os.path.join(out, b)
        cmd("convert %s %s.png"%(f,b))
