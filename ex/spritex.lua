local ej = require "ejoy2d"
local layout = require "ex.layout"

local spritex = {}
spritex.__index = spritex

-- init
function spritex.metanew()
    return setmetatable({}, spritex)
end

function spritex.new(packname, name)
    return spritex.init(spritex, packname, name)
end

function spritex.init(class, packname, name)
    local spr
    if packname then
        spr = assert(ej.sprite(packname, name))
    else
        spr = name
    end
    local x,y,x2,y2 = spr:aabb()
    return setmetatable({
        __sprite = spr,
        __w = x2-x,
        __h = y2-y,
        __x = 0,
        __y = 0,
        __scalex = 1,
        __scaley = 1,
        __anchorx = 0.5,
        __anchory = 0.5,
        __matrix_dirty = false,
        __xlayout = nil,
        __ylayout = nil,
        __maxloop = nil,
        __curloop = nil,
        __frame_run = nil,
        __frame_reverse = nil,
        __action = nil,
        __action_cb = nil,
    }, class)
end

-- matrix
function spritex:mount(...)
    local t = {...}
    for i=1,#t//2 do
        self.__sprite[t[i]] = t[i+1]
    end
    local x,y,x2,y2 = self.__sprite:aabb()
    local w,h = x2-x, y2-y
    if w ~= self.__w or h ~= self.__h then
        self.__w = w
        self.__h = h
        if self.__anchorx ~= 0 or self.__anchory ~= 0 then
            self.__matrix_dirty = true
        end
    end
end

function spritex:layout(xlayout, ylayout)
    if xlayout ~= self.__xlayout or ylayout ~= self.__ylayout then
        self.__xlayout = xlayout
        self.__ylayout = ylayout
        self.__matrix_dirty = true
    end
end

function spritex:anchorpoint(x, y)
    if x ~= self.__anchorx or y ~= self.__anchory then
        self.__anchorx = x
        self.__anchory = y
        self.__matrix_dirty = true
    end
end

function spritex:position(x, y)
    if x and x ~= self.__x then
        self.__x = x
        self.__matrix_dirty = true
    end
    if y and y ~= self.__y then
        self.__y = y
        self.__matrix_dirty = true
    end 
end

function spritex:scale(scalex, scaley)
    if scalex and scalex ~= self.__scalex then
        self.__scalex = scalex
        self.__matrix_dirty = true
    end
    if scaley and scaley ~= self.__scaley then
        self.__scaley = scaley
        self.__matrix_dirty = true
    end
end

local function __calculate_matrix(self)
    if not self.__matrix_dirty then
        return
    end
    local x = self.__xlayout and 
        layout.pointx(self.__x, self.__xlayout) or self.__x
    local y = self.__ylayout and 
        layout.pointy(self.__y, self.__ylayout) or self.__y
    
    local lscale = layout.SCALE 
    self.__sprite:ps(x, y)
    self.__sprite:sr(self.__scalex*lscale, self.__scaley*lscale, self.__rot)
    if self.__anchorx ~= 0 or self.__anchory ~= 0 then
        self.__sprite.matrix:lmul(
        matrix{x=-(self.__w*self.__anchorx),
               y=-(self.__h*self.__anchroy)})
    end
    self.__matrix_dirty = false
end

-- frame
function spritex:loop(n)
    self.__maxloop = n or 0 -- zero for endless loop
    self.__curloop = 0
end

function spritex:frame_run(n)
    if self.__sprite.frame_count > 0 then
        self.__frame_run = true 
        n = n or 1 -- loop one time by default
        self:loop(1)
    end
end

function spritex:frame_stop()
    self.__frame_run = false
end

function spritex:frame_reverse(b)
    self.__frame_reverse = b
end

function spritex:frame_reset()
    self.__sprite.frame = self.__frame_reverse and 
        self.__sprite.frame_count-1 or 0
end

-- action
function spritex:action(act, actcb)
    if act then
        if act.prepare then
            act:prepare(self)
        end
        self.__action_cb = actcb
    else
        self.__action_cb = nil
    end
    self.__action = act
    return act
end

function spritex:action_time()
    if self.__action then
        return self.__action:time()
    else
        return 0
    end
end

-- touch 
function spritex:touch_enable(b)
    local old = self.__touch_enable
    self.__touch_enable = b
    return old
end

function spritex:touch_event(type, cb)
    local old
    if type == 'down' then
        old = self.__touchdowncb
        self.__touchdowncb = cb
        return old
    elseif type == 'up' then 
        old = self.__touchupcb
        self.__touchupcb = cb
        return old
    else error("Control unknown event:"..type)
    end
end

function spritex:__ontouch_down(x,y)
    if self.__touchdowncb then
        self:__touchdowncb(self,x,y)
        return true
    end
end

function spritex:__ontouch_up(x,y)
    if self.__touchupcb then
        self:__touchupcb(self,x,y)
        return true
    end
end

function spritex:__ontouch_in(x,y) end
function spritex:__ontouch_out(x,y) end

function spritex:__ontouch(what,x,y)
    local hit = self.__sprite:test(x,y,srt)
    if what == "BEGIN" then
        if hit then 
            self.__touchstate = 'down'
            if self:__ontouch_down(x,y) then
                return 'down'
            end
        end
    elseif what == "END" then
        if hit then
            if self.__touchstate == 'down' then 
                self.__touchstate = nil
                if self:__ontouch_up(x,y) then
                    return 'up'
                end
            end
        end
    elseif what == "MOVE" then
        if hit then
            if self:__ontouch_in(x,y) then
                return 'in'
            end
        else
            if self.__touchstate == 'down' then
                self.__touchstate = nil
                if self:__ontouch_out(x,y) then
                    return 'out'
                end
            end
        end
    end
end

function spritex:touch(what,x,y)
    if self.__touch_enable then 
        return self:__ontouch(what,x,y)
    end
end

-- update
function spritex:update()
    if self.__frame_run then
        local spr = self.__sprite
        local end_frame = false
        if self.__frame_reverse then
            spr.frame = spr.frame-1
            if spr.frame < 0 then
                spr.frame = 0
                end_frame = true
            end
        else
            spr.frame = spr.frame + 1
            if spr.frame >= spr.frame_count then
                spr.frame = spr.frame_count-1
                end_frame = true
            end
        end
        if end_frame and self.__maxloop > 0 then
            self.__curloop = self.__curloop + 1
            if self.__curloop >= self.__maxloop then
                self.__frame_run = false
            end
        end
    end
    if self.__action then
        if not self.__action:update(self) then
            if self.__action_cb then
                self.__action_cb(self)
                self.__action_cb = nil
            end
            self.__action = nil
        end
    end
    __calculate_matrix(self)
end

-- draw
function spritex:draw()
    self.__sprite:draw()
end

return spritex
