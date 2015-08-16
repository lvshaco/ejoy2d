#_*_ coding:utf-8 _*_

from xml.dom import minidom
from string import Template
import os
import sys
import re
from pathutil import *

reload(sys)
sys.setdefaultencoding("utf-8")

__all__ = [
    "parsecsd",
]

CONTROL = list()

def NEW(d, node, uitype, type):
    global CONTROL
    x,y = _XY(node,"Position")
    ax,ay = _ScaleXY(node,"AnchorPoint")
    w,h = _Size(node)
    d["uitype"] = uitype
    d["type"] = type
    d["id"] = _GENID() 
    d["x"], d["y"] = x-ax*w, y-ay*h
    d["w"], d["h"] = w,h
    d["xscale"], d["yscale"] = _ScaleXY(node,"Scale")
    # 当前只支持等比例缩放
    #assert(d['xscale'] == d['yscale'])
    d['xlayout'],d['ylayout'] = _LAYOUT(node)
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

ID = -1
def _GENID():
    global ID
    ID+=1
    return ID

def _ID():
    global ID
    return ID

def _AV(node, attr, default=""):
    if node.attributes.has_key(attr):
        return node.attributes[attr].value
    else:
        return default

def _AF(node, attr, default=0):
    return float(_AV(node, attr, default))

def _AI(node, attr, default=0):
    return int(_AF(node, attr, default))

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
    xscale,yscale = _ScaleXY(node,"Scale")
    return w*xscale, h*yscale

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
def _sprite(node, d):
    # 作为animation的组件存在，不单独存在，直接引用对应的picture
    w,h=_Size(node)
    name = _AV(node,'Name')
    if name[-3:]=='[T]':
        name = name[:-3]
        d['touch'] = True
    d["export"] = name
    #d["color"] = _ARGB(node,"CColor")
    d['picture'] = _IMAGE(node, 'FileData')
    NEW(d, node, "sprite", "sprite")
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
    w,h=_Size(node)
    d["space_w"] = 0
    d["space_h"] = 0
    d["text"] = _AV(node,"LabelText")
    NEW(d, node, "label", "label")
    return d

def _editbox(node, d):
    pass

def _button(node, d):
    text_id = -1
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
        NEW(sd, node, "label", "label")
        # label高度直接改为字体大小，否则会在点击中触发到此label
        sd['h'] = sd['size']
        text_id = _ID()
    
    d["export"] = _AV(node,"Name")
    l = list()
    l.append(_IMAGE(node,"NormalFileData"))
    l.append(_IMAGE(node,"PressedFileData"))
    dis = _IMAGE(node,"DisabledFileData")
    if dis == 'Button_Disable.png': dis = ""
    l.append(dis)
    l.append(text_id)
    d['component'] = l
    d['text'] = text
    d['touch'] = True
    NEW(d,node,"button","animation")
    return d

def _checkbox(node, d):
    text_id = -1
    text = ""
    d["export"] =_AV(node,"Name")
    l = list()
    l.append(_IMAGE(node,"NormalBackFileData"))
    l.append(_IMAGE(node,"PressedBackFileData"))
    dis = _IMAGE(node,"DisableBackFileData")
    if dis == 'CheckBox_Disable.png': dis = ""
    l.append(dis)
    l.append(text_id)
    d['component'] = l
    d['text'] = text
    d['touch'] = True
    NEW(d,node,"checkbox","animation")
    return d

def _processbar(node, d):
    sd = dict()
    sd["scissor"] = True
    NEW(sd,node,"pannel","pannel")
    pannel_id = _ID()
  
    d["export"] = _AV(node,"Name")
    l = list()
    l.append(_IMAGE(node,"ImageFileData"))
    l.append(pannel_id)
    d['component'] = l
    NEW(d,node,"processbar","animation")
    return d

def _sliderbar(node, d):
    sd = dict()
    sd["export"] = ""
    l = list()
    l.append(_IMAGE(node,"BallNormalData"))
    l.append(_IMAGE(node,"BallPressedData"))
    dis = _IMAGE(node,"BallDisabledData")
    if dis == 'SliderNode_Disable.png': dis = ""
    l.append(dis)
    l.append(-1) # text_id
    sd['component'] = l
    sd['touch'] = True
    NEW(sd,node,"button","animation")
    sd['w'] = 0
    sd['h'] = 0
    degree_id = _ID()
  
    d["export"] = _AV(node,"Name")
    l = list()
    l.append(degree_id) 
    l.append(_IMAGE(node,"BackGroundData"))
    d['component'] = l
    NEW(d,node,"sliderbar","animation")
    return d

def _listview(node, d):
    sd = dict()
    sd["scissor"] = True
    NEW(sd,node,"pannel","pannel")
    pannel_id = _ID()
  
    name = _AV(node,"Name")
    if name[-1]==']':
        pos = name.rfind('[')
        if pos > 0:
            d['nitem'] = int(name[pos+1:-1])
            name = name[:pos]
    d["export"] = name
    l = list()
    l.append(_IMAGE(node,"FileData"))
    l.append(pannel_id) 
    d['component'] = l
    if not d.has_key('nitem'):
        d['nitem']=10
    NEW(d,node,"listview","animation")
    return d

def _child(node,d, addself):
    if addself:
        sd = dict()
        _sprite(node, sd)
        _addchild(d, sd)
        sd['x'], sd['y'] = 0,0
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
    'LoadingBarObjectData': _processbar,
    'SliderObjectData':     _sliderbar,
    'ListViewObjectData':   _listview,
    #'ImageViewObjectData':  _image,
    'SpriteObjectData':     _sprite,
}
def _control(node):
    d = dict()
    _child(node, d, False)
    type = _AV(node, "ctype")
    assert CONTROLS.has_key(type), "Invalid control type:"+type
    f = CONTROLS[type]
    return f(node,d)

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
            sprite = _childnodefirst(child, "AbstractNodeData")
            if _AV(sprite,'ctype')=='SpriteObjectData':
                return sprite, 3 # node, sprite as the container
            else:
                return root, 2   # node, kinds of independent control
        else:
            return root, 2
     
def parsecsd(cfgfile, startid):
    print "[+]"+cfgfile
    csdname,_ = os.path.splitext(os.path.split(cfgfile)[-1])
    global CONTROL, ID
    CONTROL = list()
    ID = -1
    dom = _open(cfgfile)
    root, rtype = _root(dom)
    d = dict()
    NEW(d, root, "composite", "animation")
    ID = startid-1
    CONTROL = list()
    if rtype == 1:
        d['screen'] = True
        _child(root,d,False)
    elif rtype == 2:
        d["noexport"] = True
        _child(root,d,False)
    elif rtype == 3:
        _child(root,d,True)
    # export name add prefix csdname_
    for c in CONTROL:
        if c.get('export'):
            c['export'] = '%s_%s'%(csdname, c['export'])
    d["id"] = _GENID()
    d["export"] = csdname
    CONTROL.append(d)
    return CONTROL
