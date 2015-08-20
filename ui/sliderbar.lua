local control = require "ui.control"
local button = require "ui.button"

local sliderbar = control.new()
sliderbar.__index = sliderbar

local function __degree(x)
    if x < 0 then x=0
    elseif x > self.range then 
        x = self.range 
    end
    if x == self.degree then 
        return 
    end
    self.degree = x 
    x = x*self.__unit - self.__degree_halfw
    self.__degree.__sprite:ps(x, self.__degree_inity)

    if self.__bar_len then -- has degree bar
        x = x*self.__unit - self.__bar_len + self.__bar_initx
        self.__sprite.bar:ps(x, self.__bar_inity)
    end
    return true
end


function sliderbar.new(packname, spr, range)
    local self = control.init(sliderbar, packname, spr)
    range = range or 100
    self.range = range

    local len
    if self.__sprite.bar then -- has degree bar
        local x1,y1,x2,_ = self.__sprite.bar:aabb()
        len = x2-x1
        self.__bar_initx = x1
        self.__bar_inity = y1
        self.__bar_len = len
        self.__unit = len/range 
    else
        local x1,_,x2,_ = self.__sprite:aabb()
        len = x2-x1
    end
    self.__unit = len/range
    self.__degree = button.new(nil, self.__sprite.degree)
    local x1,y1,x2,_ = self.__sprite.degree:aabb()
    self.__degree_halfw = (x2-x1)//2
    self.__degree_inity = y1
    
    __degree(0)
    return self
end

function sliderbar:degree(x)
    if __degree(self, x) then
        if self.__degree_cb then
            self:__degree_cb(self.degree)
        end
    end
end

function sliderbar:__ontouch(what, x, y)
    if what=='BEGIN' then
        local hit = self.__sprite:test(x,y)
        if hit then
            self.__degree:__ontouchdown(x,y)
            self.__draging = true
            return true
        end
    elseif what=='END' then
        if self.__draging then
            self.__degree:__ontouchup(x,y)
            self.__draging = false
            return true
        end
    end
    if self.__draging then
        local x1,_,x2,_ = self.__sprite:aabb() -- get current real aabb
        self:setdegree((x-x1)*self.range/(x2-x1))
        return true
    end
end

function sliderbar:touch_event(type, cb)
    if type == 'degree' then
        o = self.__degree_cb
        self.__degree_cb = cb
        return o
    else
        error("sliderbar unknow touch event:"..type)
    end
end

return sliderbar
