local control = require "ui.control"
local assert = assert

local progressbar = control.new()
progressbar.__index = progressbar

local function __degree(self, x)
    if x<0 then x = 0
    elseif x > self.__range then
        x = self.__range
    end
    if x == self.__degree then
        return 
    end
    self.__degree = x
    self.__sprite.pannel:sr(x/self.__range,1)
    return true
end

function progressbar.new(packname, spr, range)
    local self = control.construct(progressbar, packname, spr)
    range = range or 100
    self.__range = range

    __degree(self, 0)
    return self
end

function progressbar:degree(n)
    __degree(self, n)
end

function progressbar:range(n)
    assert(n > 0)
    self.__range = n
    if self.__degree > n then
        self.__degree = n
    end
end

return progressbar
