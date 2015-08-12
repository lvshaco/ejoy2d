local ej = require "ejoy2d"
local fw = require "ejoy2d.framework"
local pack = require "ejoy2d.simplepackage"

pack.load {
    pattern = fw.WorkDir..[[examples/asset/?]],
    "type1",
}

pack.load {
    pattern = fw.WorkDir..[[examples/asset/?]],
    "type2",
}

-- define a shader
--local s = ej.define_shader {
	--name = "GRAY",
--}
--gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
--s.color(1,0,0,1)	-- set shader color


local game = {}
local screencoord = { x = 512, y = 384, scale = 1.2 }

local robot = ej.sprite("type1", "robot_t1")
robot:ps(0,0,0.5)
robot.action = "act1"

local robot2_01 = ej.sprite("type2", "robot_t2_01")
robot2_01:ps(-100,0,0.5)
robot2_01.ttt.text = "abcef"

local robot2 = ej.sprite("type2", "robot_t2")
robot2:ps(100,0,0.5)
robot2.action = "act2"

function game.update()
    robot.frame = robot.frame + 2
    robot2_01.frame = robot2_01.frame + 2
    robot2.frame = robot2.frame + 2
end

function game.drawframe()
	ej.clear(0xff808080)	-- clear (0.5,0.5,0.5,1) gray
    robot:draw(screencoord)
    robot2_01:draw(screencoord)
    robot2:draw(screencoord)
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


