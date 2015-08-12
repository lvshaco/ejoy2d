#_*_ coding:utf-8 _*_

import os
import sys
from string import Template

reload(sys)
sys.setdefaultencoding("utf-8")

__all__ = [
    "combine",
]

SCREEN_SCALE = 16

def find_pic(img_l, name):
    for v in img_l:
        if v["export"] == name:
            return v
    assert False, "Cannot found picture:"+name

def find_ani(ani_l, id):
    for v in ani_l:
        if v['id'] == id:
            return v
    assert False, "Cannot found ani:"+id

def fill_id(ani_l, img_l):
    for v in ani_l:
        if v["type"] == "animation":
            uitype = v['uitype']
            # button checkbox各个帧的修复，顺带获取compenont id
            if uitype == 'button' or \
               uitype == 'checkbox':
                cs = v["component"]
                w,h = v['w'],v['h']
                frames = list()
                textid = cs[-1]
                textidx = cs[-2] and len(cs)-1 or len(cs)-2
                for i in range(len(cs)-1):
                    pic = cs[i] and find_pic(img_l, cs[i]) or None
                    if not pic: break
                    screen = pic['screen']
                    pw,ph = screen[0]*2+screen[2], screen[1]*2+screen[3]
                    if w==0 and h==0:
                        w,h=pw,ph
                        v['w'],v['h']=w,h
                    if pw==w and ph==h:
                        line = '%d'%i
                    else:
                        tranx = (w-pw)/2 * SCREEN_SCALE
                        trany = (h-ph)/2 * SCREEN_SCALE
                        # add color
                        line = '{index=%d,mat={1024,0,0,1024,%d,%d}}'%(i,tranx,trany)
                    frames.append(line)
                    cs[i] = pic and pic['id'] or -1
                for i in range(len(frames)):
                    f = frames[i]
                    if textid == -1:
                        frames[i] = '{%s}'%frames[i]
                    else:
                        label = find_ani(ani_l, textid)
                        trany = (h-label['size'])/2 * SCREEN_SCALE
                        frames[i] = '{%s,{index=%d,mat={1024,0,0,1024,0,%d}}}'%\
                        (frames[i],textidx,trany)
                v['frame'] = ',\n        '.join(frames)
            elif uitype == 'sliderbar':
                cs = v["component"]
                w,h = v['w'],v['h']
                ani = find_ani(ani_l, cs[0])
                assert(ani)
                #screen = pic['screen']
                pw,ph = ani['w'],ani['h']#screen[0]*2+screen[2], screen[1]*2+screen[3]
                if pw==w and ph==h:
                    v['frame']=''
                else:
                    tranx = 0#(w-pw)/2 * SCREEN_SCALE
                    trany = (h-ph)/2 * SCREEN_SCALE
                    # add color
                    v['frame']='mat={1024,0,0,1024,%d,%d},'%(tranx,trany)
                #cs[0] = pic['id'] 
            elif uitype == 'listview':
                cs = v['component']
                w,h = v['w'],v['h']
                if cs[0]:
                    pic = find_pic(img_l, cs[0]) 
                    v['back'] = '{id=%d},'%pic['id']
                    cs[0] = pic['id']
                else:
                    pic = None
                    v['back'] = ''
                    cs[0] = -1
                frame = list()
                start_index=0
                if pic:
                    screen = pic['screen']
                    pw,ph = screen[0]*2+screen[2], screen[1]*2+screen[3]
                    if pw==w and ph==h:
                        line = '0'
                    else:
                        tranx = (w-pw)/2 * SCREEN_SCALE
                        trany = (h-ph)/2 * SCREEN_SCALE
                        #print (w,h,pw,ph, w-pw, h-ph, tranx,trany)
                        # add color
                        line = '{index=0,mat={1024,0,0,1024,%d,%d}}'%(tranx,trany)
                    frame.append(line)
                    start_index=1
                for i in range(v['nitem']+1):
                    frame.append('{index=%d,touch=true}'%(i+start_index))
                item = list()
                for i in range(v['nitem']):
                    item.append('{name="item%d"}'%(i+1))
                v['item'] = ',\n        '.join(item)
                v['frame'] = ',\n        '.join(frame)
            #composite 添加component, frame
            elif uitype == 'composite':
                assert v.has_key('children')
                cs = v['children']
                cl = list()
                fl = list()
                for i in range(len(cs)):
                    c = cs[i]
                    id = c['id']
                    #tranx,trany = c['x']*SCREEN_SCALE, c['y']*SCREEN_SCALE
                    tranx,trany = 0,0 # layout in run
                    scalex,scaley = 1024,1024
                    if c['uitype'] == 'sprite':
                        pic = find_pic(img_l, c['picture'])
                        sx = c['w']/float(pic['screen'][2])
                        sy = c['h']/float(pic['screen'][3])
                        #tranx = int(tranx*sx)
                        #trany = int(trany*sy)
                        #scalex= int(scalex*sx) # layout in run
                        #scaley= int(scaley*sy) # layout in run
                        id = pic['id']
                    cl.append('{id=%d,name="%s"}'%(id,c['export']))
                    touch = ""
                    if c.get('touch'):
                        touch = ',touch=true'
                    if scalex==1024 and scaley==1024 and tranx==0 and trany==0:
                        line = '{index=%d%s}'%(i,touch)
                    else:
                        line = '{index=%d%s,mat={%d,0,0,%d,%d,%d}}'%\
                                (i,touch, scalex,scaley,tranx,trany)
                    fl.append(line)
                v['component'] = ',\n        '.join(cl)
                v['frame'] = '{%s}'%',\n         '.join(fl)
    # 修复动画中各个组件的ID 
    for v in ani_l:
        if v["type"] == "animation":
            uitype = v['uitype']
            if uitype != "composite":
                cs = v["component"]
                for i in range(len(cs)):
                    c = cs[i]
                    if type(c) == int:
                        continue
                    elif type(c) == str or type(c)==unicode:
                        cs[i] = cs[i] and find_pic(img_l, cs[i])['id'] or -1
                    else:
                        assert False, "Invalid animation component id:"+c


PICTURE = """
{
    type = "picture",
    id = $id,
    $export
    { tex = $tex, src = {$src}, screen = {$screen} },
},"""
LABEL = """
{
    type = "label",
    id = $id,
    $export
    color=$color, align=$align, size=$size, width=$w, height=$h, noedge=$noedge, space_w=0, space_h=0, auto_size=0
},"""
PANNEL = """
{
    type = "pannel", 
    id = $id,
    width=$w, height=$h, scissor=true,
},"""
BUTTON = """
{
    type = "animation", 
    id = $id,
    $export
    component = {
        {id=$normal},
        {id=$highlight}, $disable $label
    },
    {
        $frame
    },
},"""
CHECKBOX = """
{
    type = "animation",
    id = $id,
    $export
    component = {
        {id=$unchoose},
        {id=$choose}, $disable
    },
    {
        $frame
    },
},"""
PROCESSBAR = """
{
    type = "animation",
    id = $id,
    $export
    component = {
        {id=$bar, name="bar"},
        {id=$pannel}, 
    },
    {
        {1,0},
    },
},"""
SLIDERBAR = """
{
    type = "animation",
    id = $id,
    $export
    component = {
        {id=$degree, name="degree"},
        {id=$pannel}, 
    },
    {
        {{index=1},{index=0,$frame touch=true}},
    },
},"""
LISTVIEW = """
{
    type = "animation",
    id = $id,
    $export
    component = {
        $back{id=$pannel,name="pannel"},
        $item
    },
    {
        {$frame}
    },
},"""
COMPOSITE = """
{
    type = "animation",
    id = $id,
    $export
    component = {
        $component
    },
    {
        $frame
    },
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
def _pannel(v):
    return Template(PANNEL).substitute(v)
def _label(v):
    return Template(LABEL).substitute(v)
def _button(v):
    cs = v['component']
    v['normal'] = cs[0]
    v['highlight'] = cs[1]
    if cs[2] >= 0:
        v['disable'] = "{id=%d},"%cs[2]
    else:
        v['disable'] = ""
    if cs[3] >= 0:
        v['label'] = '{id=%d,name="label"},'%cs[3]
    else:
        v['label'] = ""
    return Template(BUTTON).substitute(v)
def _checkbox(v):   
    cs = v['component']
    v['unchoose'] = cs[0]
    v['choose'] = cs[1]
    if cs[2] >= 0:
        v['disable'] = "{id=%d},"%cs[2]
    else:
        v['disable'] = ""
    return Template(CHECKBOX).substitute(v)
def _processbar(v):
    cs = v['component']
    v['bar'] = cs[0]
    v['pannel'] = cs[1]
    return Template(PROCESSBAR).substitute(v)
def _sliderbar(v):
    cs = v['component']
    v['degree'] = cs[0]
    v['pannel'] = cs[1]
    return Template(SLIDERBAR).substitute(v)
def _listview(v):
    cs = v['component']
    v['pannel'] = cs[1]
    return Template(LISTVIEW).substitute(v)
def _composite(v):
    return Template(COMPOSITE).substitute(v)

TEMPLATES = {
    "picture":  _picture,
    "pannel":   _pannel,
    "label":    _label,
    "button":   _button,
    "checkbox": _checkbox,
    "processbar":_processbar,
    "sliderbar":_sliderbar,
    "listview": _listview,
    "composite":_composite,
}
UNEXPORT = ('sprite')

def cfg_dump(node, level, t):
    uitype = node['uitype']
    tabp = level*'  '
    tab=tabp+'  '
    t1 = list()
    t1.append('%suitype="%s"'%(tab,node['uitype']))
    t1.append('%sexport="%s", --%d'%(tab,node['export'],node['id']))
    if node.get('screen'):
        t1.append('%sscreen=true'%(tab))
    t1.append('%sxlayout="%s"'%(tab,node['xlayout']))
    t1.append('%sylayout="%s"'%(tab,node['ylayout']))
    t1.append('%sw=%d'%(tab,node['w']))
    t1.append('%sh=%d'%(tab,node['h']))
    t1.append('%sx=%d'%(tab,node['x']))
    t1.append('%sy=%d'%(tab,node['y']))
    t1.append('%sxscale=%f'%(tab,node['xscale']))
    t1.append('%syscale=%f'%(tab,node['yscale']))
    param = None
    if uitype == 'button' or \
       uitype == 'label': 
        if node['text']:
            param='"%s"'%node['text']
    elif uitype == 'listview':
        if node['nitem']:
            param='%d'%node['nitem']
    if param:
        t1.append('%sparam=%s'%(tab,param))
    if node.has_key('children'):
        for c in node['children']:
            cfg_dump(c,level+1,t1)
    t.append('%s{\n%s\n%s}'%(tabp,',\n'.join(t1),tabp))

def combine(csd_l, img_l, outpath, packname):
    if not img_l or not csd_l:
        print "None to combine"
    fcfg = os.path.join(outpath, packname+"_uc.lua") 
    print '[=]'+fcfg
    t = list()
    for ani_l in csd_l:
        com = ani_l[-1]
        #if not com.get('noexport'):
        cfg_dump(com,0,t)
        t[-1] = "%s=%s"%(com['export'], t[-1])
    f = open(fcfg, 'w')
    f.write('return {\n')
    f.write('export="%s",\n'%packname)
    f.write(',\n'.join(t))
    f.write('\n}')
    f.close()

    for ani_l in csd_l:
        fill_id(ani_l, img_l)

    t = list()
    t.append('return {')
    for v in img_l:
        if v.get('export'):
            v['export'] = 'export="%s",'%v['export']
        value = _picture(v)
        t.append(value)
    for ani_l in csd_l:
        for v in ani_l:
            if v.get('noexport'): continue
            uitype = v["uitype"]
            if uitype in UNEXPORT: continue
            assert TEMPLATES.has_key(uitype), \
                    "Unknown uitype:%s(id=%d, export=%s)"%(uitype,v['id'],v['export'])
            f = TEMPLATES[uitype]
            if v.get('export'):
                v['export'] = 'export="%s",'%v['export']
            value = f(v)
            t.append(value)
    t.append('}')

    flua = os.path.join(outpath, packname+".lua") 
    print "[=]"+flua
    f = open(flua, 'w')
    f.write("".join(t))
    f.close() 
