--[[
all spritex will scale with layout.SCALE,
this would let spritex cordinary with the design.
]]

local ej = require "ejoy2d"
local layout = {
    SCALE = 1,
    W = 1024,
    H = 768,
}

local __initw
local __inith
local __adapt -- 'W':adapt width 
              -- 'H':adapt height
              -- nil:adapt

function layout.init(w, h, adapt)
    assert(__adapt == nil)
    assert(adapt == 'W' or adapt == 'H')
    __initw = w
    __inith = h
    __adapt = adapt
    layout.SCALE = 1
    layout.resize(ej.screen())
end

function layout.resize(w, h) 
    if __adapt == 'W' then
        layout.SCALE = w/__initw
    elseif __adapt == 'H' then
        layout.SCALE = h/__inith
    end
    layout.W = w
    layout.H = h
end

function layout.pointx(v, type)
    if type == 's' then
        return v*layout.W
    elseif type == 'l' then
        return v*layout.SCALE
    elseif type == 'r' then
        return layout.W-(__initw-v)*layout.SCALE
    else
        return v*layout.W
    end
end

function layout.pointy(v, type)
    if type == 's' then
        return v*layout.H
    elseif type == 't' then
        return v*layout.SCALE
    elseif type == 'b' then
        return layout.H-(__inith-v)*layout.SCALE
    else
        return v*layout.H
    end
end

return layout
