local spritex = require "util.spritex"
local layout = require "util.layout"
local setmetatable = setmetatable
local assert = assert

local control = spritex.metanew()
control.__index = control

function control.new()
    return setmetatable({}, control)
end

function control.init(class, packname, spr, text)
    local self = spritex.init(class, packname, spr)
    if text and self.__sprite.label then
        self.__sprite.label.text = text
    end
    self.__touch_enable = true
    return self
end

function control:text(text)
    assert(self.__sprite.label)
    self.__sprite.label.text = text
end

function control:get_text()
    return self.__sprite.label.text
end

function control:enable(b)
    self:touch_enable(b)
    if self.__onenable then
        self:__onenable(b)
    end
end

return control
