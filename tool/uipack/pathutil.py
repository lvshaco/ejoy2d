import os

__all__ = [
    "hasfile",
    "getdirs",
    "getfiles",
    "getdirbase",
    "splitnumber",
    "rmdirs",
]

def hasfile(path, exts):
    for f in os.listdir(path):
        f = os.path.join(path, f)
        if os.path.isfile(f):
            _, ext = os.path.splitext(os.path.basename(f))
            if ext in exts:
                return True
    return False

def _getdirs(path, exts, maxl, l, dirs):
    if hasfile(path, exts):
        dirs.append(path)
    if l>=maxl:
        return
    for f in os.listdir(path):
        f = os.path.join(path, f)
        if not os.path.isfile(f):
            _getdirs(f, exts, maxl, l+1, dirs)

def getdirs(path, exts, maxl, dirs):
    _getdirs(path, exts, maxl, 0, dirs)

def _getfiles(path, exts, maxl, l, files):
    if l >= maxl:
        return
    for f in os.listdir(path):
        f = os.path.join(path, f) 
        if os.path.isfile(f):
            _, ext = os.path.splitext(os.path.basename(f))
            if (not exts) or (ext in exts):
                files.append(f)
        else:
            _getfiles(f, exts, maxl, l+1, files)

def getfiles(path, exts, maxl, files):
    _getfiles(path, exts, maxl, 0, files)

def getdirbase(dir):
    if dir[-1] == '/':
        dir = dir[:-1]
    if dir[-1] == '\\\\':
        dir = dir[:-2]
    i = dir.rfind("/")
    if i != -1:
        return dir[i+1:]
    i = dir.rfind('\\\\')
    if i != -1:
        return dir[i+2:]
    return dir

def splitnumber(name):
    n = len(name)
    idx = 0
    for i in range(1,n+1):
        c = name[-i]
        if c < '0' or c > '9':
            break
        idx = -i

    if idx < 0:
        return name[:n+idx], name[idx:]
    else:
        return name, ""

def rmdirs(path):
    if os.path.isfile(path):
        os.remove(path)
    elif os.path.isdir(path):
        for f in os.listdir(path):
            f = os.path.join(path, f)
            rmdirs(f)
        os.rmdir(path)
