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

#def find_ani(ani_l, id):
#    for v in ani_l:
#        if v['id'] == id:
#            return v
#    assert False, "Cannot found ani:"+id

#def pic_part(img_l, cs, i, v):
#    w,h=v['w'],v['h']
#    pic = imagefind(img_l, cs[i])
#    pw,ph = imagerange(pic)
#    if pw==w and ph==h:
#        s = '%d'%i
#    else:
#        tranx = (w-pw)/2 * SCREEN_SCALE
#        trany = (h-ph)/2 * SCREEN_SCALE
#        s = '{index=%d,mat={1024,0,0,1024,%d,%d}}'%(i,tranx,trany)
#    cs[i] = pic['id']
#    return s

def image_part(c, i, w, h):
    if c['picture'].get('scale9_id'):
        return '%d'%i
    pw,ph = imagerange(c['picture'])
    if pw==w and ph==h:
        return '%d'%i
    else:
        tranx = (w-pw)/2 * SCREEN_SCALE
        trany = (h-ph)/2 * SCREEN_SCALE
        return '{index=%d,mat={1024,0,0,1024,%d,%d}}'%(i,tranx,trany)

def ani_part(c, i ,w, h, pw=0,ph=0):
    if not pw: pw=c['w']
    if not ph: ph=c['h']
    if pw==w and ph==h:
        return '%d'%i
    else:
        tranx = (w-pw)/2 * SCREEN_SCALE
        trany = (h-ph)/2 * SCREEN_SCALE
        return '{index=%d,mat={1024,0,0,1024,%d,%d}}'%(i,tranx,trany)

def label_part(c, i, w, h):
    trany = (h-c['size'])/2 * SCREEN_SCALE
    return '{index=%d,mat={1024,0,0,1024,0,%d}}'%(i,trany)
  
def c_is_image(c):
    return c['uitype'] == 'scale9' or c['uitype'] == 'sprite'

def _id(c):
    if c_is_image(c):
        pic = c['picture']
        sid = pic.get('scale9_id')
        if sid:
            return sid
        else:
            return pic['id'] # use picture id
    else:
        return c['id']

def dump_scale9(ani_l):
    print ("-------------------------------")
    for v in ani_l:
        uitype = v['uitype']
        if uitype == 'scale9':
            print ("++", id(v), v)
    print ("-------------------------------")

def build_scale9(ani_l, img_l):
    for v in ani_l:
        uitype = v['uitype']
        if uitype == 'scale9':
            pic = v['picture']
            if pic.get('scale9_id'):
                v['noexport'] = True # don't export repeat
            else:
                pic['scale9_id'] = True
                l = imagescale9(pic, v, len(img_l))
                v['scale9_l'] = l # store scale9 to v
                img_l+=l # append scale9 to img_l

def fix_aniid(ani_l, diff):
    for v in ani_l:
        v['id'] = v['id']+diff
        if v['uitype'] == 'scale9':
            if not v.get('noexport'):
                v['picture']['scale9_id'] = v['id']


PICTURE = """
{
    type = "picture",
    id = $id,
    $export
    { tex = $tex, src = {$srcstr}, screen = {$screenstr} },
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
SCALE9 = """
{
    type = "animation",
    id = $id,
    component = {
        $com
    },
    {
        $fra
    },
},"""
ANI = """
{
    type = "animation",
    id = $id,
    $export
    component = {
        $com
    },
    {
        $fra
    },
},"""

def _range(v, scale):
    x,y,w,h=v
    if scale != 1:
        x,y,w,h = x*scale, y*scale, w*scale, h*scale
    return "%d,%d,%d,%d,%d,%d,%d,%d"%(x,y, x+w,y, x+w,y+h, x,y+h)

def _picture(v, ani_l):
    v['srcstr'] = _range(v['src'], 1)
    v['screenstr'] = _range(v['screen'], SCREEN_SCALE)
    return Template(PICTURE).substitute(v)
def _pannel(v, ani_l):
    return Template(PANNEL).substitute(v)
def _label(v, ani_l):
    return Template(LABEL).substitute(v)
def _button(v, ani_l):
    cs = v['children']
    w,h = v['w'],v['h']
    cl = list()
    fl = list()
    cl.append('{id=%d}'%_id(cs[0]))
    cl.append('{id=%d}'%_id(cs[1]))
    if v['state'] == 3:
        cl.append('{id=%d}'%_id(cs[2]))
    if v.get('text'):
        cl.append('{id=%d,name="label"}'%_id(cs[-1]))
         
    if v.get('text'):
        text_part = ','+label_part(cs[-1], len(cs)-1, w,h)
    else:
        text_part = ''

    fl.append('{%s%s}'%(image_part(cs[0], 0, w,h), text_part))
    fl.append('{%s%s}'%(image_part(cs[1], 1, w,h), text_part))
    if v['state'] == 3:
        fl.append('{%s%s}'%(image_part(cs[2], 2, w,h), text_part))
    v['com'] = ',\n        '.join(cl)
    v['fra'] = ',\n        '.join(fl)
    return Template(ANI).substitute(v) 
def _checkbox(v, ani_l):   
    cs = v['children'] 
    w,h = v['w'],v['h'] 

    parts = list()
    for i in range(len(cs)):
        parts.append(image_part(cs[i],i,w,h))

    cl = list()
    fl = list()
    cl.append('{id=%d}'%(_id(cs[0])))
    cl.append('{id=%d}'%(_id(cs[1])))
    if v['state'] == 3:
        cl.append('{id=%d}'%(_id(cs[2])))
        if v.get('hasnode'):
            cl.append('{id=%d,name="tag"}'%(_id(cs[3])))
            cl.append('{id=%d,name="disable_tag"}'%(_id(cs[4])))
            fl.append('{%s,%s}'%(parts[0],parts[3]))
            fl.append('{%s,%s}'%(parts[1],parts[3]))
            fl.append('{%s,%s}'%(parts[2],parts[3]))
        else:
            fl.append('{%s}'%parts[0])
            fl.append('{%s}'%parts[1])
            fl.append('{%s}'%parts[2])
    else:
        if v.get('hasnode'):
            cl.append('{id=%d,name="tag"}'%(_id(cs[2])))
            fl.append('{%s,%s}'%(parts[0],parts[2]))
            fl.append('{%s,%s}'%(parts[1],parts[2]))
        else:
            fl.append('{%s}'%parts[0])
            fl.append('{%s}'%parts[1])
    v['com'] = ',\n        '.join(cl)
    v['fra'] = ',\n        '.join(fl)
    return Template(ANI).substitute(v)
def _progressbar(v, ani_l):
    cs = v['children']
    w,h = v['w'],v['h']
    cl = list()
    cl.append('{id=%d}'%_id(cs[0]))
    cl.append('{id=%d,name="pannel"}'%_id(cs[1]))
    v['com'] = ',\n        '.join(cl)
    v['fra'] = '{1,0}'
    return Template(ANI).substitute(v)
def _sliderbar(v, ani_l):
    cs = v["children"]
    w,h = v['w'],v['h']
    cl = list()
    fl = list()
    cl.append('{id=%d,name="bg"}'%_id(cs[0]))
    fl.append(image_part(cs[0],0,w,h))
    if len(cs) == 2:
        cl.append('{id=%d,name="degree"}'%_id(cs[1]))
        fl.append(ani_part(cs[1],1,w,h, w))
    else:
        cl.append('{id=%d,name="bar"}'%_id(cs[1]))
        cl.append('{id=%d,name="degree"}'%_id(cs[2]))
        fl.append(ani_part(cs[1],1,w,h))
        fl.append(ani_part(cs[2],2,w,h, w))
    v['com'] = ',\n        '.join(cl)
    v['fra'] = '{%s}'%','.join(fl)
    return Template(ANI).substitute(v)
def _listview(v, ani_l):
    cs = v['children']
    w,h = v['w'],v['h']
    cl = list()
    fl = list()
    if c_is_image(cs[0]):
        cl.append('{id=%d,name="bg"}'%_id(cs[0]))
        fl.append(image_part(cs[0], 0, w,h))
        start_index=1
    else:
        start_index=0
    cl.append('{id=%d,name="pannel"}'%_id(cs[start_index]))
    for i in range(v['nitem']):
        cl.append('{name="item%d"}'%(i+1))
    for i in range(v['nitem']+1):
        fl.append('{index=%d,touch=true}'%(i+start_index))
    v['com'] = ',\n        '.join(cl)
    v['fra'] = '{%s}'%',\n        '.join(fl)
    return Template(ANI).substitute(v)
def _panel(v, ani_l):
    assert v.has_key('children')
    cs = v['children']
    cl = list()
    fl = list()
    for i in range(len(cs)):
        c = cs[i]
        cl.append('{id=%d,name="%s"}'%(_id(c),c['export']))
        if c.get('touch'):
            touch = ',touch=true'
        else:
            touch = ''
        fl.append('{index=%d%s}'%(i,touch))
    v['com'] = ',\n        '.join(cl)
    v['fra'] = '{%s}'%',\n        '.join(fl)
    return Template(ANI).substitute(v)

def _scale9(v, ani_l):
    cl = list()
    for one in v['scale9_l']:
        cl.append('{id=%d}'%one['id'])
    v['com'] = ',\n        '.join(cl)
    v['fra'] = '{0,1,2,3,4,5,6,7,8}'
    return Template(SCALE9).substitute(v)

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
    "scale9":   _scale9,
}
UNEXPORT = ('sprite')

def cfg_dump(node, level, t):
    uitype = node['uitype']
    tabp = level*'  '
    tab=tabp+'  '
    t1 = list()
    if uitype == 'scale9':
        uitype_export = 'sprite'
    else:
        uitype_export = uitype
    t1.append('%suitype="%s"'%(tab,uitype_export))
    t1.append('%sexport="%s", --%d'%(tab,node['export'],_id(node)))
    if node.get('screen'):
        t1.append('%sscreen=true'%(tab))
    t1.append('%sxlayout="%s"'%(tab,node['xlayout']))
    t1.append('%sylayout="%s"'%(tab,node['ylayout']))
    t1.append('%sw=%d'%(tab,node['w']))
    t1.append('%sh=%d'%(tab,node['h']))

    t3 = list()
    if uitype == 'scale9':
        t3.append('reset_scale9={%d,%d}'%(node['w'],node['h']))
    t1.append('%sinit0={%s}'%(tab,(',\n%s  '%tab).join(t3)))
    t2 = list()
    if node['x']!=0 or node['y']!=0:
        t2.append('pos={%d,%d}'%(node['x'],node['y']))
    if node['xscale']!=1.0 or node['yscale']!=1.0:
        t2.append('scalexy={%f,%f}'%(node['xscale'],node['yscale']))
    if node.get('text'):
        t2.append('text="%s"'%(node['text']))
    if node.get('nitem'):
        t2.append('nitem=%d'%(node['nitem']))
    t1.append('%sinit={%s}'%(tab,(',\n%s  '%tab).join(t2)))
    if uitype == 'panel': # now just need panel 
        if node.has_key('children'):
            for c in node['children']:
                cfg_dump(c,level+1,t1)
    t.append('%s{\n%s\n%s}'%(tabp,',\n'.join(t1),tabp))

def combine(csd_l, img_l, outpath, packname):
    if not img_l or not csd_l:
        print "None to combine"
    
    #dump_scale9(ani_l)
    diff = len(img_l)
    for ani_l in csd_l: 
        build_scale9(ani_l, img_l)
    diff = len(img_l)-diff
    #dump_scale9(ani_l)
    for ani_l in csd_l:
        fix_aniid(ani_l, diff)
    #dump_scale9(ani_l)

    fcfg = os.path.join(outpath, packname+"_uc.lua") 
    print '[=]'+fcfg
    t = list()
    for ani_l in csd_l:
        ani = ani_l[0]
        #if not com.get('noexport'):
        assert ani['uitype'] == 'panel'
        cfg_dump(ani,0,t)
        t[-1] = "%s=%s"%(ani['export'], t[-1])
    f = open(fcfg, 'w')
    f.write('return {\n')
    f.write('export="%s",\n'%packname)
    f.write(',\n'.join(t))
    f.write('\n}')
    f.close()

    t = list()
    t.append('return {')
    for v in img_l:
        if v.get('export'):
            v['export'] = 'export="%s",'%v['export']
        value = _picture(v, None)
        t.append(value)

    #dump_scale9(ani_l)
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
