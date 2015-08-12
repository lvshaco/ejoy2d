local control = require "util.control"
local button = require "util.button"
local layout = require "util.layout"

local setmetatable = setmetatable
local assert = assert

local sliderbar = control.new()
sliderbar.__index = sliderbar

function sliderbar.new(packname, spr, range)
    local self = control.init(sliderbar, packname, spr)
    local _,y1,_,y2 = self.__sprite.back:aabb()
    self.__h = y2-y1
    range = range or 100
    self.range = range
    self.degree = 0
    self.__degree = button.new(nil, self.__sprite.degree)
    local x1,_,x2,_ = self.__sprite:aabb()
    self.__unit = (x2-x1)/range
    local x1,_,x2,_ = self.__sprite.degree:aabb()
    self.__degree_hw = (x2-x1)//2
    return self
end

function sliderbar:setdegree(x)
    if x < 0 then x=0
    elseif x > self.range then 
        x = self.range 
    end
    if x == self.degree then return end
    self.degree = x 
    x = x*self.__unit-self.__degree_hw
    self.__degree.__sprite:ps(x,0)

    if self.__degreecb then
        self:__degreecb(self.degree)
    end
end

function sliderbar:__ontouch(what, x, y)
    if what=='BEGIN' then
        local hit = self.__sprite:test(x,y)
        if hit then
            self.__degree:__ontouch_down(x,y)
            self.__draging = true
        end
    elseif what=='END' then
        if self.__draging then
            self.__degree:__ontouch_up(x,y)
            self.__draging = false
        end
    end
    if self.__draging then
        local x1,_,x2,_ = self.__sprite:aabb()
        local w=x2-x1
        self:setdegree((x-x1)*self.range/w)
    end
end

function sliderbar:touch_event(type, cb)
    if type == 'degree' then
        old = self.__degreecb
        self.__degreecb = cb
        return old
    end
end

return sliderbar
