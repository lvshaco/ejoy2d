local ej = require "ejoy2d"
local sprite = require "ejoy2d.sprite"
local layout = require "util.layout"

local spritex = {}
spritex.__index = spritex

function spritex.metanew()
    return setmetatable({}, spritex)
end

function spritex.new(packname, name)
    return spritex.init(spritex, packname, name)
end

function spritex.init(class, packname, name)
    local spr
    if packname then
        spr = assert(sprite.new(packname, name))
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
        __scale = 1,
        __anchorx = 0.5,
        __anchory = 0.5,
    }, class)
end

function spritex:bound(...)
    local t = {...}
    for i=1,#t//2 do
        self.__sprite[t[i]] = t[i+1]
    end
    local x,y,x2,y2 = self.__sprite:aabb()
    self.__w, self.__h = x2-x, y2-y
end

function spritex:xy(ax,ay)
    local x1,y1,x2,y2 = self.__sprite:aabb()
    local w,h = x2-x1, y2-y1
    if ax and ay then
        return self.__x+(ax-self.__anchorx)*w, self.__y+(ay-self.__anchory)*h
    else
        return self.__x, self.__y
    end
end

function spritex:wh()
    return self.__w, self.__h
end

function spritex:visible(b)
    self.__sprite.visible = b
end

function spritex:draw()
    self.__sprite:draw()
end

function spritex:anchorpoint(x,y)
    self.__anchorx = x
    self.__anchory = y
end

function spritex:scale(f)
    --self.__scale = f
    --f = layout.fix(f)
    --self.__sprite:ps(f)
    self:ps(self.__x, self.__y, f)
end

function spritex:ps(x,y,f,xtype,ytype)
    if xtype then
        x = layout.pointx(x,xtype)
    end
    if ytype then
        y = layout.pointy(y,ytype)
    end
    if f then
        self.__scale = f
    else
        f = self.__scale
    end
    self.__x = x
    self.__y = y
    f = layout.fix(f)
    local w,h = self.__w*f, self.__h*f
    local x = x-w*self.__anchorx
    local y = y-h*self.__anchory
    
    self.__sprite:ps(x,y,f)
end

function spritex:setloop(x)
    self.__maxloop = x
    self.__curloop = 0
end

function spritex:reverse(b)
    self.__reverse = b
end

function spritex:reset_frame()
    self.__sprite.frame = self.__reverse and 
        self.__sprite.frame_count-1 or 0
end

function spritex:start_ani()
    self.__run_ani = true
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

-- touch event
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
    if self.__run_ani then
        local spr = self.__sprite
        local bend = false
        if self.__reverse then
            spr.frame = spr.frame-1
            if spr.frame < 0 then
                spr.frame = 0
                bend = true
            end
        else
            spr.frame = spr.frame + 1
            if spr.frame > spr.frame_count-1 then
                spr.frame = spr.frame_count-1
                bend = true
            end
        end
        if bend then
            if self.__maxloop and 
               self.__maxloop > 1 then
                self.__curloop = self.__curloop + 1
                if self.__curloop >= self.__maxloop then
                    self.__run_ani = false
                end
            else
                self.__run_ani = false
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
end

function spritex:draw()
    self.__sprite:draw()
end

return spritex
