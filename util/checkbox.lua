local control = require "util.control"
local setmetatable = setmetatable
local assert = assert

local checkbox = control.new()
checkbox.__index = checkbox

local UNCHOOSE = 0
local CHOOSE = 1
local DISABLE = 2

function checkbox.new(packname, spr, text)
    return control.init(checkbox, packname, spr, text)
end

local function __change_state(self, state)
    self.__sprite.frame = state
end

function checkbox:__ondisable()
    __change_state(self, DISABLE)
end

local function __choose(self, x, y, state)
    __change_state(self, state)
    if self.__touchdowncb then
        self:__touchdowncb(self,state)
    end
end

function checkbox:__ontouch_down(x,y)
    if self.__sprite.frame == UNCHOOSE then
        __choose(self, x, y, CHOOSE)
        return true
    elseif self.__sprite.frame == CHOOSE then
        __choose(self, x, y, UNCHOOSE)
        return true
    end
end

return checkbox
