local control = require "ui.control"

local editbox = control.new()
editbox.__index = editbox

function editbox.new(packname, spr)
    local self = control.construct(editbox, packname, spr)
    self.__focus = false
    self.__text = ''
    self.__password_mode = false
    return self
end

function editbox:password_mode(on)
    self.__password_mode = on
end

function editbox:text(text)
    self.__text = text
    if self.__password_mode then
        self.__sprite.label.text = string.rep('*', #self.__text)
    else
        self.__sprite.label.text = text
    end
end

function editbox:get_text()
    return self.__text
end

function editbox:input_key(key)
    if self.__focus then
        self:text(self.__text..c)
    end
end

function editbox:__touchdown(x,y)
    self:set_focus(true)
end

return editbox
