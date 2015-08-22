local control = require "ui.control"
local button = require "ui.button"
local progressbar = require "ui.progressbar"

local sliderbar = control.new()
sliderbar.__index = sliderbar

local function __degree(self, x)
    if x < 0 then x=0
    elseif x > self.__range then 
        x = self.__range 
    end
    if x == self.__degree then 
        return 
    end
    self.__degree = x 
    -- degreebtn is child sprite, dont care scale, etc.
    -- so not need realtime calculate the unit
    self.__degreebtn:pos(x*self.__unit , 0)
    if self.__bar then -- has degree bar
        self.__bar:degree(x)
    end
    return true
end

function sliderbar:update()
    self.__degreebtn:update()
    control.update(self)
end

function sliderbar.new(packname, spr, range)
    local self = control.init(sliderbar, packname, spr)
    range = range or 100
    self.__range = range
    local x1,_,x2,_ = self.__sprite.back:aabb()
    self.__unit = (x2-x1)/self.__range
    if self.__sprite.bar then -- has degree bar
        self.__bar = progressbar.new(nil, self.__sprite.bar, range)
    end
    self.__degreebtn = button.new(nil, self.__sprite.degree)
    self.__degreebtn:anchorpoint(0.5, 0)
    __degree(self, 0)
    return self
end

function sliderbar:__onenable(enable)
    self.__degreebtn:__onenable(enable)
end

function sliderbar:degree(x)
    if __degree(self, x) then
        if self.__degree_cb then
            self:__degree_cb(self.__degree)
        end
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

local function __click_degree(self,x)
    local x1,_,x2,_ = self.__sprite.back:aabb(nil,true) 
    self:degree((x-x1)*self.__range//(x2-x1))
end

function sliderbar:__touchdown(x,y)
    self.__degreebtn:__ontouchdown(x,y)
    __click_degree(self,x)
end

function sliderbar:__touchup(x,y)
    if self.__touchstate == 'down' then
        self.__degreebtn:__ontouchup(x,y)
        self.__draging = false
    end
end

function sliderbar:__touchmove(x,y)
    if self.__touchstate == 'down' then
        __click_degree(self,x)
    end
end

return sliderbar
