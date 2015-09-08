package.path = package.path..";ex/?.lua;tool/?.lua"
local argparse = require "argparse"
local png = require "png"
local tbl = require "tbl"
local msqrt = math.sqrt
local mfloor = math.floor

local g_strength
local g_t, g_w, g_h, g_p ,g_step
local g_o = {}

local function intensity(x, y)
    if x > g_w-1 then x = g_w-1
    elseif x < 0 then x = 0
    end
    if y > g_h-1 then y = g_h-1
    elseif y < 0 then y = 0
    end
    local i = (y *g_w + x) * g_step
    return (g_p[i+1] + g_p[i+2] + g_p[i+3]) / 3 / 255
end

local function normalize(x,y,z)
    local l = msqrt(x*x + y*y + z*z)
    return x/l, y/l, z/l
end

local function tocolor(x)
    --return (x+1)/2 * 255
    return mfloor((x+1)/2 * 255)
end

local function pixel(x, y, r, g, b)
    local i = (y *g_w + x) * 3
    g_o[i+1] = r 
    g_o[i+2] = g 
    g_o[i+3] = b
end

local t1 = os.clock()
local args = argparse({...},
    {i={dest='heightmap', required=true},
     o={dest='normalmap', required=true},
     s={dest='strength',default=5}})

g_dz = 1/args.strength
g_t, g_w, g_h, g_p = png.load(args.heightmap)
g_step = #g_p/(g_w*g_h)
--print (g_t, g_w, g_h, g_p, g_step)
for y=0, g_h-1 do
    for x=0, g_w-1 do
        local tl = intensity(x-1,y-1)
        local t  = intensity(x,  y-1)
        local tr = intensity(x+1,y-1)
        local r  = intensity(x+1,y)
        local br = intensity(x+1,y+1)
        local b  = intensity(x,  y+1)
        local bl = intensity(x-1,y+1)
        local l  = intensity(x-1,y)
        
        -- sobel filter
        local dx = (tr + 2 * r + br) - (tl + 2 * l + bl)
        local dy = (bl + 2 * b + br) - (tl + 2 * t + tr)
        local dz = g_dz

        dx,dy,dz = normalize(dx,dy,dz)
        local i = (y*g_w + x) * 3
        g_o[i+1] = tocolor(dx)
        g_o[i+2] = tocolor(dy)
        g_o[i+3] = tocolor(dz)
    end
end

png.save(args.normalmap, 'RGB8', g_w, g_h, g_o) 
local t2 = os.clock()
print ('use time:'..(t2-t1))
