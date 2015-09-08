package.path = package.path..";ex/?.lua;tool/?.lua"
local argparse = require "argparse"
local png = require "png"
local tbl = require "tbl"
local msqrt = math.sqrt
local mfloor = math.floor

local g_w, g_h, g_depth

local function RGB2L(R,G,B)
    L = R * 299/1000 + G * 587/1000 + B * 114/1000
    return L
end

local function image(p, step)
    local o = {}
    local idx
    for i=0, g_h*g_w-1 do
        idx = i*step
        o[i+1] = RGB2L(p[idx+1], p[idx+2], p[idx+3])/255
    end
    return o
end

local function fill(value)
    local o = {}
    for i=1, g_h*g_w do
        o[i] = value
    end
    return o
end

local function delta(f1, f2)
    local o = {}
    for i=1, g_h*g_w do
        o[i] = f1[i] - f2[i]
    end
    return o
end

local function rangefix(f)
    for i=1, g_h*g_w do
        f[i] = (f[i]+1)/2
    end
end

local function rangez(f)
    for i=1, g_h*g_w do
        f[i] = (f[i] * g_depth) + (1-g_depth)
    end
end

local function tocolor(fx, fy, fz)
    local o = {}
    local idx
    for i=0, g_h*g_w-1 do
        idx = i*3
        o[idx+1] = mfloor(fx[i+1]*255)
        o[idx+2] = mfloor(fy[i+1]*255)
        o[idx+3] = mfloor(fz[i+1]*255)
    end
    return o
end

local args = argparse({...},
    {l={dest='left'},
    r={dest='right'},
    t={dest='top'},
    b={dest='bottom'},
    o={dest='normalmap', required=true},
    d={dest='depth', default=0.5}})

g_depth = args.depth
local t1 = os.clock()
local inputs = {{},{},{},{}}
inputs[1].file = args.left
inputs[2].file = args.right
inputs[3].file = args.top
inputs[4].file = args.bottom

local ninputs = 0
for _, v in ipairs(inputs) do
    if v.file then
        v.t, v.w, v.h, v.data = png.load(v.file)
        assert(v.t == 'RGBA8' or v.t == 'RGB8', 'unknown color type:'..v.t)
        v.step = #v.data / (v.w*v.h)
        g_w = v.w
        g_h = v.h
        ninputs = ninputs + 1
    end
end
assert(ninputs>0, 'no input')

for _, v in ipairs(inputs) do
    assert(v.w == nil or v.w == g_w, 'no same w')
    assert(v.h == nil or v.h == g_h, 'no same h')
end

for _, v in ipairs(inputs) do
    if v.data then
        v.fdata = image(v.data, v.step)
    else
        v.fdata = fill(0.5)
    end
end

local x_N = delta(inputs[2].fdata, inputs[1].fdata)
local y_N = delta(inputs[3].fdata, inputs[4].fdata)
local z_N = {}
for i=1, g_h*g_w do
    --Assume N = (x_N, y_N, z_N) to be a unit vector, i.e.,
    --N dot N = 1
    --Hence, z_N^2 = 1 - x_N^2 - y_N^2. Otherwise if
    --x_N^2 + y_N^2 >= 1 then z_N = 0.
    local v = x_N[i]*x_N[i] + y_N[i]*y_N[i]
    --z_N[i] = v>=1 and 0 or ((1-(v/(v^0.5)))^0.5)
    z_N[i] = v>=1 and 0 or ((1-v)^0.5)
end

-- Transform x_N, y_N from the -1.0..1.0 range to 0.0..1.0.
rangefix(x_N)
rangefix(y_N)
-- Compress z_N range. This can be done for aesthetic reasons or due to
-- 3D engine requirements (e.g., Doom 3).
rangez(z_N)

local o = tocolor(x_N, y_N, z_N)
png.save(args.normalmap, 'RGB8', g_w, g_h, o) 
local t2 = os.clock()
print ('use time:'..(t2-t1))
