local sprite = require "ejoy2d.sprite"
local ej = require "ejoy2d"
local fps = {}
local label, time, tick
function fps.init()
    label = sprite.label{width=100, height=18,color=0xffffffff,align='left'}
    time, tick = 0,0
    local _,sh = ej.screen()
    label:ps(0, sh-18)
end
function fps.update(elapsed)
    time = time + elapsed
    tick = tick + 1
    if time >= 1 then
        label.text = string.format('%.2f F/S', tick/time)
        time, tick = 0,0
    end
end
function fps.draw()
    label:draw()
end
return fps
