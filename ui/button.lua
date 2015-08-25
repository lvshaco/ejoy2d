local control = require "ui.control"

local button = control.new()
button.__index = button

-- state cordinary to sprite frame
local NORMAL = 0
local HIGHLIGHT = 1
local DISABLE = 2

function button.new(packname, spr)
    local self = control.construct(button, packname, spr)
    return self
end

function button:text(text)
    if self.__sprite.label then
        self.__sprite.label.text = text
    end
end

function button:get_text()
    return self.__sprite.label.text
end

local function __change_state(self, state)
    self.__sprite.frame = state
end

function button:__onenable(enable)
    if enable then
        if self.__sprite.frame == DISABLE then
            __change_state(self, NORMAL)
        end
    else
        if self.__sprite.frame ~= DISABLE then
            if self.__sprite.frame_count == 3 then
                __change_state(self, DISABLE)
            end
        end
    end
end

function button:__touchdown(x,y)
    __change_state(self, HIGHLIGHT)
end

function button:__touchup(x,y)
    __change_state(self, NORMAL)
end

function button:__touchout(x,y)
    __change_state(self, NORMAL)
end

function button:reset_scale9(w,h)
    local p = self.__sprite
    control.reset_scale9(self, w,h, p:fetch_by_index(0))
    control.reset_scale9(self, w,h, p:fetch_by_index(1))
    if self.__sprite.frame_count > 2 then
        control.reset_scale9(self,w,h, p:fetch_by_index(2))
    end
end

return button
