local ej = require "ejoy2d"
local fw = require "ejoy2d.framework"
local pack = require "ejoy2d.simplepackage"
local matrix = require "ejoy2d.matrix"
local spritex = require "ex.spritex"

pack.load {
	pattern = fw.WorkDir..[[examples/asset/?]],
	"image",
}

local o0 = spritex.new("image", 0)
local o1 = spritex.new("image", 0)
local o2 = spritex.new("image", 0)
local o3 = spritex.new("image", 0)
local o4 = spritex.new("image", 0)
local o5 = spritex.new("image", 0)
local o6 = spritex.new("image", 0)

local w, h = o0.__w, o0.__h

o0:anchorpoint(0,0)
o1:anchorpoint(0,0)
o2:anchorpoint(1,1)
o3:anchorpoint(0.5,0.5)
o4:anchorpoint(0,0)
o5:anchorpoint(1,1)
o6:anchorpoint(0.5,0.5)

o0:pos(100,100)
o1:pos(100,100)
o2:pos(100+w,100+h)
o3:pos(100+w/2,100+h/2)
o4:pos(100,100)
o5:pos(100+w,100+h)
o6:pos(100+w/2,100+h/2)

o4:scale(2)
o5:scale(2)
o6:scale(2)

local game = {}

local rot = 0
function game.update()
    rot = rot+1
    if rot == 360 then
        rot = 0
    end
    o1:rot(rot)
    o2:rot(rot)
    o3:rot(rot)
    o4:rot(rot)
    o5:rot(rot)
    o6:rot(rot)
    
    o0:update()
    o1:update()
    o2:update()
    o3:update()
    o4:update()
    o5:update()
    o6:update()
end

function game.drawframe()
	ej.clear(0xff808080)	-- clear (0.5,0.5,0.5,1) gray
    o6:draw()
    o5:draw()
    o4:draw()
    o0:draw()
    o3:draw()
    o2:draw()
    o1:draw()
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
