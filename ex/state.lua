local ej = require "ejoy2d"

local state = {}

local S

function state.change(to,...)
    assert(to)
    if S then
        S.exit()
    end
    S = to
    if S then
        S.enter(...)
        state.resize(ej.screen())
    end
end

function state.update(dt)
    if S and S.layer then
        S.layer:update(dt)
    end
end

function state.drawframe()
    if S and S.layer then
        S.layer:draw()
    end
end

function state.touch(what,x,y)
    if S then
        if S.layer then
            if S.layer:touch(what,x,y) then
                return
            end
        end
        if S.touch then
            S.touch(what,x,y)
        end
    end
end

function state.resize(w,h)
    if S then
        if S.layer then
            S.layer:resize(w,h)
        end
        if S.resize then
            S.resize(w,h)
        end
    end
end

return state
