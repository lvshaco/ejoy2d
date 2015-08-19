local control = require "util.control"
local setmetatable = setmetatable
local assert = assert

local label = control.new()
label.__index = label

function label.new(packname, spr, text)
    local self = control.init(label, packname, spr, "")
    if text then
        self.__sprite.text = text
    end
    return self
end

return label
