local ej = require "ejoy2d"
local layout = {
    SCALE = false,
}

local __sw
local __sh
local __sw_ori
local __sh_ori
local __adapt -- 'W':adapt width 
              -- 'H':adapt height
              -- nil:adapt

function layout.init(sw, sh, adapt)
    __sw_ori = sw
    __sh_ori = sh
    SCALE = 1
    __adapt = adapt
    layout.resize(ej.screen())
end

function layout.resize(w, h) 
    if __adapt == 'W' then
        SCALE = w/__sw_ori
    elseif __adapt == 'H' then
        SCALE = h/__sh_ori
    end
    __sw = w
    __sh = h
end

function layout.pointx(v, type)
    if type == 's' then
        return v*__sw
    elseif type == 'l' then
        return v*SCALE
    elseif type == 'r' then
        return __sw-(__sw_ori-v)*SCALE
    else
        return v*__sw
    end
end

function layout.pointy(v, type)
    if type == 's' then
        return v*__sh
    elseif type == 't' then
        return v*SCALE
    elseif type == 'b' then
        return __sh-(__sh_ori-v)*SCALE
    else
        return v*__sh
    end
end

function layout.fix(v)
    return v*SCALE
end

function layout.fixr(v)
    return v/SCALE
end

function layout.wh()
    return __sw, __sh
end

return layout
