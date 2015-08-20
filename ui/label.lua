local control = require "ui.control"

local label = control.new()
label.__index = label

function label.new(packname, spr, text)
    local self = control.init(label, packname, spr, "")
    if text then
        self.__sprite.text = text
    end
    return self
end

function label:text(text)
    self.__sprite.text = text
end

function label:get_text()
    return self.__sprite.text
end

return label
