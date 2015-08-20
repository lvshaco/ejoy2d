local spritex = require "ex.spritex"
local setmetatable = setmetatable
local assert = assert

local control = spritex.metanew()
control.__index = control

function control.new()
    return setmetatable({}, control)
end

function control.init(class, packname, spr)
    local self = spritex.init(class, packname, spr)
    self.__touch_enable = true
    return self
end

function control:enable(b)
    self:touch_enable(b)
    if self.__onenable then
        self:__onenable(b)
    end
end

return control
