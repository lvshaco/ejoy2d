#_*_ coding:utf-8 _*_

import os
import sys
from string import Template
from parseimage import *

reload(sys)
sys.setdefaultencoding("utf-8")

__all__ = [
    "combine",
]

SCREEN_SCALE = 16

def calc_mat(pw,ph, w, h):
    if pw==w and ph==h:
        return ''
    else:
        tranx = (w-pw)/2 * SCREEN_SCALE
        trany = (h-ph)/2 * SCREEN_SCALE
        return 'mat={1024,0,0,1024,%d,%d},'%(tranx,trany)

def find_ani(ani_l, id):
    for v in ani_l:
        if v['id'] == id:
            return v
    assert False, "Cannot found ani:"+id

def pic_part(img_l, cs, i, v):
    w,h=v['w'],v['h']
    pic = imagefind(img_l, cs[i])
    pw,ph = imagerange(pic)
    if pw==w and ph==h:
        s = '%d'%i
    else:
        tranx = (w-pw)/2 * SCREEN_SCALE
        trany = (h-ph)/2 * SCREEN_SCALE
        s = '{index=%d,mat={1024,0,0,1024,%d,%d}}'%(i,tranx,trany)
    cs[i] = pic['id']
    return s

def label_part(ani_l, textid, textidx, w, h):
    if textid == -1:
        return None
    else:
        label = find_ani(ani_l, textid)
        trany = (h-label['size'])/2 * SCREEN_SCALE
        return '{index=%d,mat={1024,0,0,1024,0,%d}}'%(textidx,trany)
    
def fill_id(ani_l, img_l):
    for v in ani_l:
        if v["type"] == "animation":
            uitype = v['uitype']
            # button checkbox各个帧的修复，顺带获取compenont id
            if uitype == 'button':
                cs = v['component']
                w,h = v['w'],v['h']
                parts = list() 
                for i in range(len(cs)-1):
                    part = pic_part(img_l, cs, i, v)
                    parts.append(part)
                l_part = label_part(ani_l, cs[-1], len(cs)-1, w, h)
                l_part = l_part and ','+l_part or ''
                frames = list()
                frames.append('{%s%s}'%(parts[0],l_part))
                frames.append('{%s%s}'%(parts[1],l_part))
                if len(parts) == 3:
                    frames.append('{%s%s}'%(parts[2],l_part))
                v['frame'] = ',\n        '.join(frames)
            elif uitype == 'checkbox':
                cs = v['component']
                w,h = v['w'],v['h']
                parts = list() 
                for i in range(len(cs)):
                    part = pic_part(img_l, cs, i, v)
                    parts.append(part)
                frames = list()
                if len(parts) == 3:
                    frames.append('{%s,%s}'%(parts[0],parts[2]))
                    frames.append('{%s,%s}'%(parts[0],parts[2]))
                elif len(parts) == 5:
                    frames.append('{%s,%s}'%(parts[0],parts[3]))
                    frames.append('{%s,%s}'%(parts[1],parts[3]))
                    frames.append('{%s,%s}'%(parts[2],parts[4]))
                v['frame'] = ',\n        '.join(frames)
            elif uitype == 'sliderbar':
                cs = v["component"]
                w,h = v['w'],v['h']
                
                back = imagefind(img_l, cs[0])
                pw,ph = imagerange(back)
                v['back_frame'] =  calc_mat(pw,ph,w,h)
                
                degree = find_ani(ani_l, cs[1])
                v['degree_frame'] = calc_mat(w,degree['h'],w,h)

                if len(cs) == 3:
                    bar = find_ani(ani_l, cs[2])
                    v['bar_frame'] = ',{index=2,%s}'%calc_mat(bar['w'], bar['h'], w,h)
                else:
                    v['bar_frame'] = ''
            elif uitype == 'listview':
                cs = v['component']
                w,h = v['w'],v['h']
                if cs[0]:
                    pic = imagefind(img_l, cs[0]) 
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
            #panel 添加component, frame
            elif uitype == 'panel':
                assert v.has_key('children')
                cs = v['children']
                cl = list()
                fl = list()
                #print ("+++++++++", 'pannel:cs:', len(cs), v)
                for i in range(len(cs)):
                    c = cs[i]
                    #tranx,trany = c['x']*SCREEN_SCALE, c['y']*SCREEN_SCALE
                    tranx,trany = 0,0 # layout in run
                    scalex,scaley = 1024,1024
                    if c['uitype'] == 'sprite':
                        pic = imagefind(img_l, c['picture'])
                        sx = c['w']/float(pic['screen'][2])
                        sy = c['h']/float(pic['screen'][3])
                        tranx = int(tranx*sx)
                        trany = int(trany*sy)
                        scalex= int(scalex*sx) # layout in run
                        scaley= int(scaley*sy) # layout in run
                        id = pic['id']
                    else:
                        id = c['id']
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
            if uitype != "panel":
                cs = v["component"]
                for i in range(len(cs)):
                    c = cs[i]
                    if type(c) == int:
                        continue
                    elif type(c) == str or type(c)==unicode:
                        cs[i] = cs[i] and imagefind(img_l, cs[i])['id'] or -1
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
        {id=$normal},
        {id=$highlight}, $disable
        $node, $node_disable
    },
    {
        $frame
    },
},"""
PROGRESSBAR = """
{
    type = "animation",
    id = $id,
    $export
    component = {
        {id=$bar},
        {id=$pannel, name="pannel"}, 
    },
    {
        {$pannel_frame,0},
    },
},"""
SLIDERBAR = """
{
    type = "animation",
    id = $id,
    $export
    component = {
        {id=$back, name="back"}, 
        {id=$degree, name="degree"}, $bar
    },
    {
        {{index=0,$back_frame}$bar_frame,{index=1,$degree_frame},},
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
PANEL = """
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

def _picture(v, ani_l):
    v['src'] = _range(v['src'], 1)
    v['screen'] = _range(v['screen'], SCREEN_SCALE)
    return Template(PICTURE).substitute(v)
def _pannel(v, ani_l):
    return Template(PANNEL).substitute(v)
def _label(v, ani_l):
    return Template(LABEL).substitute(v)
def _button(v, ani_l):
    cs = v['component']
    v['normal'] = cs[0]
    v['highlight'] = cs[1]
    if len(cs) == 4:
        v['disable'] = "{id=%d},"%cs[2]
    else:
        v['disable'] = ""
    if cs[-1] >= 0:
        v['label'] = '{id=%d,name="label"},'%cs[-1]
    else:
        v['label'] = ""
    return Template(BUTTON).substitute(v)
def _checkbox(v, ani_l):   
    cs = v['component']
    v['normal'] = cs[0]
    v['highlight'] = cs[1]
    if len(cs) == 3:
        v['disable'] = ''
        v['node'] = '{id=%d,name="tag"}'%cs[2]
        v['node_disable'] = ''
    elif len(cs) == 5:
        v['disable'] = cs[2]
        v['node'] = '{id=%d,name="tag"}'%cs[3]
        v['node_disable'] = '{id=%d,name="disable_tag"}'%cs[4]
    return Template(CHECKBOX).substitute(v)
def _progressbar(v, ani_l):
    cs = v['component']
    v['bar'] = cs[0]
    v['pannel'] = cs[1]
    pannel = find_ani(ani_l, cs[1])
    mat = calc_mat(pannel['w'], pannel['h'], v['w'], v['h'])
    v['pannel_frame'] = mat and '{index=1,%s}'%mat or '1'
    return Template(PROGRESSBAR).substitute(v)
def _sliderbar(v, ani_l):
    cs = v['component']
    v['back'] = cs[0]
    v['degree'] = cs[1]
    if len(cs) == 3:
        v['bar'] = '{id=%d,name="bar"}'%cs[2]
    else:
        v['bar'] = ''
    return Template(SLIDERBAR).substitute(v)
def _listview(v, ani_l):
    cs = v['component']
    v['pannel'] = cs[1]
    return Template(LISTVIEW).substitute(v)
def _panel(v, ani_l):
    return Template(PANEL).substitute(v)

TEMPLATES = {
    "picture":  _picture,
    "pannel":   _pannel,
    "label":    _label,
    "button":   _button,
    "checkbox": _checkbox,
    "progressbar":_progressbar,
    "sliderbar":_sliderbar,
    "listview": _listview,
    "panel":_panel,
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
    t2 = list()
    t2.append('pos={%d,%d}'%(node['x'],node['y']))
    t2.append('scalexy={%f,%f}'%(node['xscale'],node['yscale']))
    if node.get('text'):
        t2.append('text="%s"'%(node['text']))
    if node.get('nitem'):
        t2.append('nitem=%d'%(node['nitem']))
    t1.append('%sinit={%s}'%(tab,(',\n%s  '%tab).join(t2)))
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
        value = _picture(v, None)
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
            value = f(v, ani_l)
            t.append(value)
    t.append('}')

    flua = os.path.join(outpath, packname+".lua") 
    print "[=]"+flua
    f = open(flua, 'w')
    f.write("".join(t))
    f.close() 
