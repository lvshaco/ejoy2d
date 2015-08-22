local control = require "ui.control"

local checkbox = control.new()
checkbox.__index = checkbox

-- state cordinary to sprite frame
local NORMAL = 0
local HIGHLIGHT = 1
local DISABLE = 2

function checkbox.new(packname, spr)
    local self = control.init(checkbox, packname, spr)
    self.__selected = true
    return self
end

function checkbox:selected(selected)
    self.__selected = selected or false
    if self.__sprite.frame ~= DISABLE then
        self.__sprite.tag.visible = selected
    else
        self.__sprite.disable_tag.visible = selected
    end
end

local function __change_state(self, state)
    self.__sprite.frame = state
end

function checkbox:__onenable(enable)
    if enable then
        if self.__sprite.frame == DISABLE then
            __change_state(self, NORMAL)
        end
    else
        if self.__sprite.frame ~= DISABLE then
            __change_state(self, DISABLE)
        end
    end
end

function checkbox:__touchdown(x,y)
    __change_state(self, HIGHLIGHT)
end

function checkbox:__touchup(x,y)
    __change_state(self, NORMAL)
    self:selected(not self.__selected)
end

function checkbox:__touchout(x,y)
    __change_state(self, NORMAL)
end

return checkbox
