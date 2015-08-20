local control = require "ui.control"

local processbar = control.new()
processbar.__index = processbar

local function __degree(self, x)
    if x<0 then x = 0
    elseif x > self.range then
        x = self.range
    end
    if x == self.degree then
        return 
    end
    self.degree = x
    local x = x*self.__unit - self.__len + self.__bar_initx
    self.__sprite.bar:ps(x, self.__bar_inity)
    return true
end

function processbar.new(packname, spr, range)
    local self = control.init(processbar, packname, spr)
    range = range or 100
    self.range = range

    local x1,y1,x2,_ = self.__sprite.bar:aabb()
    local w = x2-x1

    self.__unit = w/range
    self.__len = w
    self.__bar_initx = x1
    self.__bar_inity = y1
    __degree(self, 0)
    return self
end

function processbar:degree(x)
    __degree(self, x)
end

return processbar
