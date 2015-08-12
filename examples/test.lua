local ej = require "ejoy2d"
local audio = require "util.audio"

assert(audio.init())

local a = audio.load("examples/asset/loginScene.mp3")
local a2 = audio.load("examples/asset/beiji.wav")
print (a.gain)
a.gain = 0.5
a.loop = true
print (a.gain)
print (a.loop)
--a:play()

a2.loop = true
--a2:play()

local turnon = false

local game = {}

function game.update()
end

function game.drawframe()
	ej.clear(0xff808080)	-- clear (0.5,0.5,0.5,1) gray
end

function game.touch(what, x, y)
    if what == "END" then
        turnon = not turnon
        if turnon then
            a:play()
            a2:play()
        else
            a:pause()
            a2:pause()
        end
    end
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

