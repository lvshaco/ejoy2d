local control = require "util.control"
local setmetatable = setmetatable
local assert = assert

local button = control.new()
button.__index = button

local NORMAL = 0
local HIGHLIGHT = 1
local DISABLE = 2

function button.new(packname, spr, text)
    return control.init(button, packname, spr, text)
end

local function __change_state(self, state)
    self.__sprite.frame = state
end

function button:__ondisable()
    __change_state(self, DISABLE)
end

function button:__ontouch_down(x,y)
    if self.__sprite.frame == NORMAL then
        __change_state(self, HIGHLIGHT)
        if self.__touchdowncb then
            self:__touchdowncb(self,x,y)
        end
        return true
    end
end

function button:__ontouch_up(x,y)
    if self.__sprite.frame == HIGHLIGHT then
        __change_state(self, NORMAL)
        if self.__touchupcb then
            self:__touchupcb(self,x,y)
        end
        return true
    end
end

function button:__ontouch_out(x,y)
    if self.__sprite.frame == HIGHLIGHT then
        __change_state(self, NORMAL)
        return true
    end
end

return button
