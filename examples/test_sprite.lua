local ej = require "ejoy2d"
local fw = require "ejoy2d.framework"
local pack = require "ejoy2d.simplepackage"
local matrix = require "ejoy2d.matrix"

pack.load {
	pattern = fw.WorkDir..[[examples/asset/?]],
	"image",
}

local o1 = ej.sprite("image",0)
local o2 = ej.sprite("image", 0)
local o3 = ej.sprite("image", 0)
local o4 = ej.sprite("image", 0)
local o5 = ej.sprite("image", 0)
local o6 = ej.sprite("image", 0)

-- set position (-100,0) scale (0.5)
o1:ps(100, 100)
o2:ps(100,100)
local game = {}
--local screencoord = { x = 512, y = 384, scale = 1.2 }
local x1,y1,x2,y2 = o1:aabb()
local w, h = x2-x1, y2-y1
    
    local m2 = matrix{scale=2}
    local m3 = matrix{x=100-w/2, y=100-h/2}
    local m = matrix()
    m = m:mul(m2)
    m = m:mul(m3)
    print (tostring(m))
   
    local m1 = matrix{x=-w/2, y=-h/2}
    local m2 = matrix{scale=2}
    local m3 = matrix{x=100+w/2, y=100+h/2}
    local mm = matrix(m1)
    mm = mm:mul(m2)
    mm = mm:mul(m3)
    print (tostring(mm))

local rot = 0
function game.update()
    rot = rot+1
    if rot == 360 then
        rot = 0
    end
    o2:sr(rot)
    local m1 = matrix{x=-w/2, y=-h/2}
    local m2 = matrix{rot=rot}
    local m3 = matrix{x=100+w/2, y=100+h/2}
    m1 = m1:mul(m2)
    m1 = m1:mul(m3)
    o3.matrix = m1
    local m1 = matrix{x=-w/2, y=-h/2}
    local m2 = matrix{rot=rot, scale=2}
    local m3 = matrix{x=100+w/2, y=100+h/2}
    m1 = m1:mul(m2)
    m1 = m1:mul(m3)
    o4.matrix = m1

    local m1 = matrix{x=-w, y=-h}
    local m2 = matrix{rot=rot}
    local m3 = matrix{x=100+w, y=100+h}
    m1 = m1:mul(m2)
    m1 = m1:mul(m3)
    o5.matrix = m1
    local m1 = matrix{x=-w, y=-h}
    local m2 = matrix{rot=rot, scale=2}
    local m3 = matrix{x=100+w, y=100+h}
    m1 = m1:mul(m2)
    m1 = m1:mul(m3)
    o6.matrix = m1
end

function game.drawframe()
	ej.clear(0xff808080)	-- clear (0.5,0.5,0.5,1) gray
    o4:draw()
    o6:draw()
    o5:draw()
	o1:draw()
    o2:draw()
    o3:draw()
end

function game.touch(what, x, y)
end

function game.message(...)
end

function game.handle_error(...)
end

function game.on_resume()
end

function game.on_pause()
end

ej.start(game)
