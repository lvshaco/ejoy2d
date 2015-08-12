local control = require "util.control"
local setmetatable = setmetatable
local assert = assert

local processbar = control.new()
processbar.__index = processbar

function processbar.new(packname, spr, range)
    local self = control.init(processbar, packname, spr)
    range = range or 100
    self.range = range
    self.degree = 0

    local x1,y1,x2,_ = self.__sprite.bar:aabb()
    local w = x2-x1
    
    self.__unit = w/range
    self.__len = w
    self.__orix = x1
    self.__oriy = y1
    return self
end

function processbar:update(x)
    if x > self.range then
        x = self.range
    end
    self.degree = x
    local x = x*self.__unit - self.__len + self.__orix
    self.__sprite.bar:ps(x, self.__oriy)
end

return processbar
