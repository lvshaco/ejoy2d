package.path = package.path..";ex/?.lua;tool/?.lua"
local argparse = require "argparse"
local png = require "png"
local tbl = require "tbl"
local msqrt = math.sqrt
local mfloor = math.floor

local args, opts = argparse({...}, 2, nil, 
    "usage: h2n.lua left right top bottom normal_file")

local g_strength = 2
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
    local i = (y *g_w + x) * g_step
    g_o[i+1] = r 
    g_o[i+2] = g 
    g_o[i+3] = b
    if g_step == 4 then
        g_o[i+4] = g_p[i+4]
    end
end

local hfile = args[1]
local nfile = args[2]

g_t, g_w, g_h, g_p = png.load(hfile)
g_step = #g_p/(g_w*g_h)
print (g_t, g_w, g_h, g_p, g_step)
print (g_p[1], g_p[2], g_p[3], g_p[4])
for y=0, g_h-1 do
    for x=0, g_w-1 do
        local tl = intensity(x-1,y-1)
        local t  = intensity(x,y-1)
        local tr = intensity(x+1,y-1)
        local r  = intensity(x+1,y)
        local br = intensity(x+1,y+1)
        local b  = intensity(x,y+1)
        local bl = intensity(x-1,y+1)
        local l  = intensity(x-1,y)
        
        -- sobel filter
        local dx = (tr + 2 * r + br) - (tl + 2 * l + bl);
        local dy = (bl + 2 * b + br) - (tl + 2 * t + tr);
        local dz = 1 / g_strength;

        local i = (y*g_w + x) + g_step
        if g_p[i+1] ~= 127 or
           g_p[i+2] ~= 127 or
           g_p[i+3] ~= 127 then
            print (dx, dy, dz, g_p[i+1], g_p[i+2], g_p[i+3])
        end
        dx,dy,dz = normalize(dx,dy,dz)
        if g_p[i+1] ~= 127 or
           g_p[i+2] ~= 127 or
           g_p[i+3] ~= 127 then
            print (dx, dy, dz, tocolor(dx), tocolor(dy), tocolor(dz), g_p[i+4])
        end

        pixel(x,y, tocolor(dx), tocolor(dy), tocolor(dz))
    end
end

png.save(nfile, g_t, g_w, g_h, g_o) 
