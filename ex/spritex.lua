local ej = require "ejoy2d"
local matrix = require "ejoy2d.matrix"
local matrix_c = require "ejoy2d.matrix.c"
local layout = require "ex.layout"
local scale9 = require "ex.scale9"
local setmetatable = setmetatable
local assert = assert

local spritex = {}
spritex.__index = spritex

-- init
function spritex.metanew()
    return setmetatable({}, spritex)
end

function spritex.new(packname, name)
    return spritex.construct(spritex, packname, name)
end

function spritex.construct(class, packname, name)
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
        __rot = nil,
        __scalex = 1,
        __scaley = 1,
        __anchorx = 0.5,
        __anchory = 0.5,
        __matrix_dirty = true, 
        __xlayout = 'l',
        __ylayout = 't',
        __maxloop = nil,
        __curloop = nil,
        __aniname = nil,
        __frame = nil,
        __frame_run = nil,
        __frame_reverse = nil,
        __frame_speed = nil,
        __action = nil,
        __action_cb = nil,
        __touch_enable = nil,
        __touchdown_cb = nil,
        __touchup_cb = nil,
        __touchstate = nil,
    }, class)
end

function spritex:init(cfg)
    for k, v in pairs(cfg) do
        if type(v) == 'table' then
            self[k](self, table.unpack(v))
        else
            self[k](self, v)
        end
    end
end

-- matrix
local function __resetwh(self, w, h)
    if w ~= self.__w or h ~= self.__h then
        self.__w, self.__h = w,h
        if self.__anchorx ~= 0 or self.__anchory ~= 0 then
            self.__matrix_dirty = true
        end
        return true
    end
end

function spritex:mount(...)
    local t = {...}
    for i=1,#t//2 do
        self.__sprite[t[i]] = t[i+1]
    end
    local x,y,x2,y2 = self.__sprite:aabb()
    __resetwh(self, x2-x, y2-y)
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

function spritex:pos(x, y)
    if x ~= self.__x or y ~= self.__y then
        self.__x = x
        self.__y = y
        self.__matrix_dirty = true
    end
end

function spritex:rot(rot)
    if rot ~= self.__rot then
        self.__rot = rot
        self.__matrix_dirty = true
    end
end

function spritex:scale(scale)
    self:scalexy(scale, scale)
end

function spritex:scalexy(scalex, scaley)
    if scalex ~= self.__scalex or scaley ~= self.__scaley then
        self.__scalex = scalex
        self.__scaley = scaley
        self.__matrix_dirty = true
    end
end

function spritex:real_wh()
    local x1,y1,x2,y2 = self.__sprite:aabb(nil,true)
    return x2-x1, y2-y1
end

function spritex:__transform()
    if not self.__matrix_dirty then
        return
    end
    local x, y, lscale
    --if self.__xlayout then
    --    x = layout.pointx(self.__x, self.__xlayout)
    --    y = layout.pointy(self.__y, self.__ylayout)
    --    lscale = layout.SCALE 
    --else
        x = self.__x
        y = self.__y
        lscale = 1
    --end
    self.__sprite:ps(x, y)
    if self.__rot then
        self.__sprite:sr(self.__scalex*lscale, self.__scaley*lscale, self.__rot)
    else
        self.__sprite:sr(self.__scalex*lscale, self.__scaley*lscale)
    end
    if self.__anchorx ~= 0 or self.__anchory ~= 0 then
        matrix_c.lmul(self.__sprite.matrix,
            matrix{x=-(self.__w*self.__anchorx),
                   y=-(self.__h*self.__anchory)})
    end
    self.__matrix_dirty = false
end

-- frame
function spritex:ani(name, n)
    if self.name then
        print ('switch action:' ,name, self.name)
    end
    self.__sprite.action = name
    self.__aniname = name
    self:frame_run(n)
    local x1,y1,x2,y2 = self.__sprite:aabb()
    __resetwh(self, x2-x1, y2-y1)
end

function spritex:loop(n)
    self.__maxloop = n or 0 -- zero for endless loop
    self.__curloop = 0
end

function spritex:frame_run(n)
    if self.__sprite.frame_count > 0 then
        self.__frame_run = true 
        self.__frame = 0
        if not self.__frame_speed then
            self.__frame_speed = 1
        end
        n = n or 0 
        self:loop(n)
    end
end

function spritex:frame_stop()
    self.__frame_run = false
end

function spritex:frame_speed(n)
    self.__frame_speed = n
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

-- util
function spritex:visible(b)
    self.__sprite.visible = b or false
end

-- touch 
function spritex:touch_enable(b)
    local o = self.__touch_enable
    self.__touch_enable = b
    return o
end

function spritex:touch_event(type, cb)
    local o 
    if type == 'down' then
        o = self.__touchdown_cb
        self.__touchdown_cb = cb
        return o
    elseif type == 'up' then 
        o = self.__touchup_cb
        self.__touchup_cb = cb
        return o
    else error("spritex unknown touch event:"..type)
    end
end

function spritex:__ontouchdown(x,y,hit)
    self.__touchstate = 'down' 
    if self.__touchdown then -- subclass implement this
        self:__touchdown(x,y,hit)
        if self.__touchdown_cb then
            self:__touchdown_cb(self,x,y)
        end
        return true
    end
    if self.__touchdown_cb then
        self:__touchdown_cb(self,x,y)
        return true
    end
end

function spritex:__ontouchup(x,y)
    self.__touchstate = 'none'
    if self.__touchup then -- subclass implement this
        self:__touchup(x,y)
        if self.__touchup_cb then
            self:__touchup_cb(self,x,y)
        end
        return true
    end
    if self.__touchup_cb then
        self:__touchup_cb(self,x,y)
        return true
    end
end

function spritex:__ontouchmove(x,y)
    if self.__touchmove then
        self:__touchmove(x,y)
    end
end

function spritex:__ontouchout(x,y)
    self.__touchstate = 'none' 
    if self.__touchout then
        self:__touchout(x,y)
        return true
    end
end

--[[subclass implement the under method to catch touch event
__touchdown
__touchup
__touchmove
__touchout
]]
function spritex:__ontouch(what,x,y)
    if what == 'BEGIN' then
        local hit = self.__sprite:test(x,y)
        if hit then
            return self:__ontouchdown(x,y,hit)
        end
    elseif what == 'END' then
        if self.__touchstate == 'down' then 
            return self:__ontouchup(x,y)
        end
    elseif what == 'MOVE' then
        if self.__touchstate == 'down' then
            if self.__touchmove then
                return self:__ontouchmove(x,y)
            elseif self.__touchout then
                local hit = self.__sprite:test(x,y)
                if not hit then
                    return self:__ontouchout(x,y)
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
function spritex:update(dt)
    if self.__frame_run then
        local nframe
        self.__frame = self.__frame + dt*24*self.__frame_speed
        if self.__frame >= 1 then
            nframe = self.__frame//1
            self.__frame = self.__frame - nframe
            local spr = self.__sprite
            local end_frame = false
            if self.__frame_reverse then
                spr.frame = spr.frame-nframe
                if spr.frame < 0 then
                    spr.frame = spr.frame_count-1--0
                    end_frame = true
                end
            else
                spr.frame = spr.frame + nframe
                if spr.frame >= spr.frame_count then
                    spr.frame = 0--spr.frame_count-1
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
    end
    if self.__action then
        if not self.__action:update(dt, self) then
            if self.__action_cb then
                self.__action_cb(self)
                self.__action_cb = nil
            end
            self.__action = nil
        end
    end
    self:__transform()
end

-- draw
function spritex:draw()
    -- perhaps no update yield
    self:__transform()
    self.__sprite:draw()
end

-- scale9
function spritex:__reset_scale9(w,h)
    if not self.__scale9 then
        self.__scale9 = scale9.new(self.__sprite)
    end
    self.__scale9:reset(self.__sprite, w, h)
end

function spritex:reset_scale9(w,h)
    local reset
    if not self.__scale9state then
        self.__scale9state = true
        reset = true
    end
    if __resetwh(w, h) then
        reset = true
    end
    if reset then
        self:__reset_scale9(w,h)
    end
end

return spritex
