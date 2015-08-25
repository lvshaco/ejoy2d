#_*_ coding:utf-8 _*_

from xml.dom import minidom
from string import Template
import os
import sys
import re
from pathutil import *
from parseimage import *

reload(sys)
sys.setdefaultencoding("utf-8")

__all__ = [
    "parsecsd",
]

IMG_L = list()
def calc_size(*cs):
    global IMG_L
    wmax,hmax=0,0
    for c in cs:
        if c.get('picture'):
            w,h=imagerange(c['picture'])
            if w>wmax: wmax=w
            if h>hmax: hmax=h
    return wmax, hmax

CONTROL = list()

def NEW(d, node, uitype):
    global CONTROL
    x,y = _XY(node,"Position")
    ax,ay = _ScaleXY(node,"AnchorPoint")
    w,h = _Size(node)
    d["uitype"] = uitype
    d["id"] = _GENID() 
    d["x"], d["y"] = x-ax*w, y-ay*h
    d["w"], d["h"] = w,h
    d["xscale"], d["yscale"] = _ScaleXY(node,"Scale")
    #assert(d['xscale'] == d['yscale'])
    d['xlayout'],d['ylayout'] = _LAYOUT(node)
    d['touch'] = _TOUCH(node)
    CONTROL.append(d)

def _open(cfgfile):
    """
    打开xml
    """
    fp = open(cfgfile, "r")
    s = fp.read()
    fp.close()
    try:
        charset = re.compile(".*\s*encoding=\"([^\"]+)\".*", re.M).match(s).group(1)
    except:
        charset = "utf-8"
    if charset.upper() != "UTF-8":
        s = re.sub(charset, "UTF-8", s)
        s = s.decode(charset).encode("UTF-8")
    try:
        dom = minidom.parseString(s)
    except Exception, e:
        print("[error : %s]\n"%str(e))
        exit(1)
    return dom

ID = 0
def _GENID():
    global ID
    i = ID
    ID+=1
    return i

def _ID():
    global ID
    return ID-1

def _AV(node, attr, default=""):
    if node.attributes.has_key(attr):
        return node.attributes[attr].value
    else:
        return default

def _AF(node, attr, default=0):
    return float(_AV(node, attr, default))

def _AI(node, attr, default=0):
    return int(_AF(node, attr, default))

def _TOUCH(node):
    enable = _AV(node, 'TouchEnable')
    return enable == 'True'

def _ALIGN(node):
    t = _AV(node,"HorizontalAlignmentType")
    if t=="HT_Center":
        return 2
    elif t=="HT_Right":
        return 1
    #elif t=="HT_Left":
        #return 0
    else:
        return 0

def _LAYOUT(node):
    e = _AV(node,"HorizontalEdge")
    if e == 'RightEdge':
        x = 'r'
    elif e == 'BothEdge':
        x = 'c'
    else:
        x = 'l'
    e = _AV(node,"VerticalEdge")
    if e == 'BottomEdge':
        y = 'b'
    elif e == 'BothEdge':
        y = 'c'
    else:
        y = 't'
    return x,y

def _XY(node,name):
    node = node.getElementsByTagName(name)[0]
    x = _AF(node,"X")
    y = _AF(node,"Y")
    return x,y

def _WH(node,name):
    w,h = _XY(node,name)
    return int(w), int(h)

def _Size(node):
    w,h = _WH(node, 'Size')
    #xscale,yscale = _ScaleXY(node,"Scale")
    #return w*xscale, h*yscale
    return w,h

def _ScaleXY(node,name):
    node = node.getElementsByTagName(name)[0]
    x = _AF(node,"ScaleX")
    y = _AF(node,"ScaleY")
    return x,y

def _ARGB(node, name):
    node = node.getElementsByTagName(name)[0]
    return "0x%02x%02x%02x%02x"%(_AI(node,"A"), _AI(node,"R"), 
            _AI(node,"G"), _AI(node,"B"))

def _IMAGE(node, name):
    node = node.getElementsByTagName(name)
    if node:
        node = node[0]
        s = _AV(node,"Path")
        return s.split("/")[-1]
        #return "\"%s\""%s.split("/")[-1]
    else:
        return ""

def _scale9_enable(node):
    yes = _AV(node,'Scale9Enable')
    return yes == 'True'

def _SCALE9(d,node):
    if _scale9_enable(node):
        d['scale9enable'] = True
        d['scale9x'] = _AI(node,'Scale9OriginX','') # use default '' to report error
        d['scale9y'] = _AI(node,'Scale9OriginY','')
        d['scale9w'] = _AI(node,'Scale9Width','')
        d['scale9h'] = _AI(node,'Scale9Height','')
        return True

##################################################
STACK = list()
    
def _addchild(d, sd):
    if not d.has_key('children'):
        d['children'] = list()
    d['children'].append(sd)

def _ENTER(node, d):
    global STACK
    if STACK: 
        p = STACK[-1]
        _addchild(p, d)
    STACK.append(d)

def _LEAVE(node):
    global STACK
    del STACK[-1]

#################################################
def _panel(node, d):
    d["export"] =_AV(node,'Name')
    #d["color"] = _ARGB(node,"CColor")
    NEW(d, node, "panel")
    #d['x'], d['y'] = 0,0 # force pos to zero
    sd = dict()
    if _imagex(node, sd, 'FileData', '_bg'): # panel no background
        sd['x'], sd['y'] = 0,0 # force pos to zero
        _addchild(d, sd)
    return d

def _imagex(node, d, field='FileData',export=''):
    d = _image(node, d, field)
    if d: 
        if export:
            d['export'] += export
        else:
            d['export'] = ''
    return d

def _image(node, d, field='FileData'):
    global IMG_L
    d["export"] =_AV(node,'Name')
    pic = _IMAGE(node, field)
    if pic:
        d['picture'] = imagefind(IMG_L, pic)
        _SCALE9(d, node)
        NEW(d, node, 'sprite')
        return d

def _label(node, d):
    name = _AV(node,'Name')
    if name[-3:]=='[E]':
        name = name[:-3]
        d["noedge"] = "false"
    else:
        d["noedge"] = "true"
    d["export"] = name
    d["color"] = _ARGB(node,"CColor")
    d["align"] = _ALIGN(node)
    d["size"] = _AI(node,"FontSize")
    d["space_w"] = 0
    d["space_h"] = 0
    d["text"] = _AV(node,"LabelText")
    NEW(d, node, "label")
    return d

def _editbox(node, d):
    pass

def _button(node, d):
    NEW(d,node,"button")

    d["export"] = _AV(node,"Name")

    sd = dict()
    assert _imagex(node, sd, "NormalFileData")
    _addchild(d, sd)

    sd = dict()
    assert _imagex(node, sd, "PressedFileData")
    _addchild(d, sd)

    sd = dict()
    if _imagex(node, sd, "DisabledFileData"):
        _addchild(d, sd)
        state = 3
    else:
        state = 2
    text = _AV(node,"ButtonText")
    text = text.strip()
    if text:
        sd = dict()
        sd["export"] = ""
        sd["color"] = _ARGB(node,"TextColor")
        sd["align"] = 2
        sd["size"] = _AI(node,"FontSize") 
        sd["noedge"] = "true"
        sd["space_w"] = 0
        sd["space_h"] = 0
        sd["text"] = text
        NEW(sd, node, "label")
        # label高度直接改为字体大小，否则会在点击中触发到此label
        sd['h'] = sd['size']
        _addchild(d,sd)

        d['text'] = text
    d['state'] = state
    if _scale9_enable(node):
        d['scale9enable'] = True
    return d

def _checkbox(node, d):
    d["export"] =_AV(node,"Name")
   
    sd = dict()
    assert _imagex(node, sd, "NormalBackFileData")
    _addchild(d, sd)

    sd = dict()
    assert _imagex(node, sd, "PressedBackFileData")
    _addchild(d, sd)

    sd = dict()
    if _imagex(node, sd, "DisableBackFileData"):
        _addchild(d, sd)
        state = 3
    else:
        state = 2
  
    sd = dict()
    if _imagex(node, sd, "NodeNormalFileData"):
        _addchild(d, sd)
        if state == 3:
            sd = dict()
            assert _imagex(node, sd, "NodeDisableFileData")
            _addchild(d, sd)
        d['hasnode'] = True
    d['state'] = state
    NEW(d,node,"checkbox")
    return d

def _progressbar(node, d):
    NEW(d,node,"progressbar")
    
    d["export"] = _AV(node,"Name")

    sd = dict()
    assert _imagex(node, sd, "ImageFileData")
    _addchild(d, sd)

    sd = dict()
    sd["scissor"] = True
    NEW(sd,node,"pannel")
    _addchild(d, sd)
    return d

def _sliderbar(node, d):
    NEW(d,node,"sliderbar")
    d["export"] = _AV(node,"Name")

    # back
    sd = dict()
    assert _imagex(node, sd, 'BackGroundData')
    _addchild(d, sd)
 
    # progressbar: bar
    sd1 = dict()
    if _imagex(node, sd1, "ProgressBarData"):
        sd = dict()
        sd["export"] = ""#_AV(node,"Name")
        
        _addchild(sd, sd1)
        w, h = imagerange(sd1['picture'])

        sd2 = dict()
        sd2["scissor"] = True
        NEW(sd2,node,"pannel")
        sd2['w'], sd2['h'] = w,h
        _addchild(sd, sd2)

        NEW(sd,node,"progressbar")
        sd['w'] = w
        sd['h'] = h
        _addchild(d, sd)

    # button: degree
    sd = dict()
    sd["export"] = ""
    
    sd1 = dict()
    assert _imagex(node, sd1, "BallNormalData")
    _addchild(sd, sd1)

    sd2 = dict()
    assert _imagex(node, sd2, "BallPressedData")
    _addchild(sd, sd2)

    sd3 = dict()
    if _imagex(node, sd3, "BallDisabledData"):
        _addchild(sd, sd3)
        state = 3
    else:
        state = 2
    sd['state'] = state
    w,h = calc_size(sd1, sd2, sd3)
    NEW(sd,node,"button")
    sd['w'] = w
    sd['h'] = h
    _addchild(d, sd)
    return d

def _listview(node, d):
    NEW(d,node,"listview")

    name = _AV(node,"Name")
    if name[-1]==']':
        pos = name.rfind('[')
        if pos > 0:
            d['nitem'] = int(name[pos+1:-1])
            name = name[:pos]
    d["export"] = name
    if not d.has_key('nitem'):
        d['nitem']=10
   
    sd = dict()
    assert _imagex(node, sd, 'FileData')
    _addchild(d, sd)

    sd = dict()
    sd["scissor"] = True
    NEW(sd,node,"pannel")
    _addchild(d, sd)
   
    if _scale9_enable(node):
        d['scale9enable'] = True
    return d

def _child(node,d):
    _ENTER(node,d)
    for child in node.childNodes:
        if child.nodeType == child.ELEMENT_NODE and \
           child.nodeName == "Children":
            for obj in child.childNodes:
                if obj.nodeType == obj.ELEMENT_NODE and \
                   obj.nodeName == "AbstractNodeData":
                       sd = _control(obj)
                       assert(sd)
                       # 编辑器y轴方向向上的
                       sd['y'] = d['h']-sd['y']-sd['h']

            break
    _LEAVE(node)

CONTROLS = {
    'TextObjectData':       _label,
    'TextFieldObjectData':  _editbox,
    'ButtonObjectData':     _button,
    'CheckBoxObjectData':   _checkbox,
    'LoadingBarObjectData': _progressbar,
    'SliderObjectData':     _sliderbar,
    'ListViewObjectData':   _listview,
    'ImageViewObjectData':  _image,
    'PanelObjectData':      _panel,
}
def _control(node):
    d = dict()
    type = _AV(node, "ctype")
    assert CONTROLS.has_key(type), "Invalid control type:"+type
    f = CONTROLS[type]
    f(node,d)
    _child(node, d)
    return d

def _childnodecnt(node, name):
    i = 0
    for c in node.childNodes:
        if c.nodeType == c.ELEMENT_NODE and \
           c.nodeName == name:
            i+=1
    return i

def _childnodefirst(node, name):
    for c in node.childNodes:
        if c.nodeType == c.ELEMENT_NODE and \
           c.nodeName == name:
            return c

def _uniquechild(node, name):
    i = _childnodecnt(node, name)
    assert i==1, "Node must own the unique child:"+name
    return _childnodefirst(node, name)

def _root(dom): 
    root = dom.getElementsByTagName("ObjectData")
    assert len(root) > 0
    root = root[0]
    w,h = _Size(root)
    if w!=0 and h!=0: 
        return root, 1 # scene, layer
    else: 
        child = _uniquechild(root, "Children")
        n = _childnodecnt(child, "AbstractNodeData")
        assert n>0, "No child node"
        if n==1:
            panel = _childnodefirst(child, "AbstractNodeData")
            if _AV(panel,'ctype')=='PanelObjectData':
                return panel, 3 # node, panel as the container
            else:
                return root, 2   # node, kinds of independent control
        else:
            return root, 2
     
def parsecsd(cfgfile, startid, img_l):
    global IMG_L,CONTROL,ID
    IMG_L = img_l
    print "[+]"+cfgfile
    csdname,_ = os.path.splitext(os.path.split(cfgfile)[-1])
    CONTROL = list()
    ID=startid
    dom = _open(cfgfile)
    root, rtype = _root(dom)
    #print( 'root type:', rtype)
    if rtype == 1:
        d = dict()
        NEW(d, root, "panel")
        d['screen'] = True
        d['export'] = csdname
        _child(root,d)
    elif rtype == 2:
        d = dict()
        NEW(d, root, "panel")
        d["noexport"] = True
        d['export'] = csdname
        _child(root,d)
    elif rtype == 3:
        d = _control(root)
    return {'name':csdname, 'l':CONTROL}
