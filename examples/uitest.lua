local ej = require "ejoy2d"
local fw = require "ejoy2d.framework"
local pack = require "ejoy2d.simplepackage"
local label = require "util.label"
local button = require "util.button"
local checkbox = require "util.checkbox"
local processbar = require "util.processbar"
local composite = require "util.composite"
local ui_image = require "examples.asset.ui_image_uc"

pack.load {
    pattern = fw.WorkDir..[[examples/asset/?]],
    "ui_image"
}
local game = {}
local screencoord = { x = 0, y = 0, scale = 1.0 }

local com = composite.new(ui_image.export,ui_image[1])

function game.update()
    --local degree = pb.degree
    --degree = degree + 1
    --if degree > pb.range then
        --degree = pb.range
    --end
    --pb:update(degree)
end

function game.drawframe()
	ej.clear(0xff808080)	-- clear (0.5,0.5,0.5,1) gray
    com:draw()
end

function game.touch(what, x, y)
    com:touch(what, x,y)
end

function game.on_resize(w,h)
    logger.log("game.on_reisze:",w,h)
    com:resize(w,h)
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
