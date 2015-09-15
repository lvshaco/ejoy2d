--[[
all spritex will scale with layout.SCALE,
this would let spritex cordinary with the design.
]]

local ej = require "ejoy2d"
local sw,sh = ej.screen()
local layout = {
    SCALE = 1,
    ADAPT = false, -- 是否强制适配所有spritex
}

local __initw = sw
local __inith = sh
local __w = sw
local __h = sh
local __adapt -- 'W':adapt width 
              -- 'H':adapt height
              -- nil:adapt

function layout.adapt(w, h, adapt)
    assert(__adapt == nil)
    assert(adapt == 'W' or adapt == 'H')
    __initw = w
    __inith = h
    __adapt = adapt
    layout.SCALE = 1
    layout.ADAPT = true
    layout.resize(ej.screen())
end

function layout.resize(w, h) 
    if __adapt == 'W' then
        layout.SCALE = w/__initw
    elseif __adapt == 'H' then
        layout.SCALE = h/__inith
    end
    __w = w
    __h = h
end

function layout.pointx(v, type)
    if type == 's' then
        return v*__w
    elseif type == 'l' then
        return v*layout.SCALE
    elseif type == 'r' then
        return __w-(__initw-v)*layout.SCALE
    else
        return v*__w
    end
end

function layout.pointy(v, type)
    if type == 's' then
        return v*__h
    elseif type == 't' then
        return v*layout.SCALE
    elseif type == 'b' then
        return __h-(__inith-v)*layout.SCALE
    else
        return v*__h
    end
end

function layout.wh()
    return __initw, __inith
end

return layout
