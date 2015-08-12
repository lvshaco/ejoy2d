-- This example show how user defined shader works

local ej = require "ejoy2d"
local fw = require "ejoy2d.framework"
local shader = require "ejoy2d.shader"
local ppm = require "ejoy2d.ppm"

local TEXID = 0

-- load ppm/pgm file into texture slot TEXID
ppm.texture(TEXID,fw.WorkDir.."examples/asset/water")

-- define a shader
local s = ej.define_shader {
	name = "NORMAL",
	fs = [[
uniform sampler2D texture0;
uniform vec2 resolution;
uniform vec3 overlayColor;
uniform vec2 iGlobalTime;
varying vec2 v_texcoord;

void main() {
    //iGlobalTime = 0;
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    float sepoffset = 0.0;//0.005*cos(iGlobalTime.x*3.0);
    if (-uv.y < 0.6)
    {
        gl_FragColor = texture2D(texture0, vec2(uv.x, -uv.y));
        //gl_FragColor = texture2D(texture0, v_texcoord);
    }
    else
    {
        

       // float xoffset = 0.005*cos(iGlobalTime.x*3.0+200.0*uv.y);
        //float yoffset = ((0.3 - uv.y)/0.3) * 0.05*(1.0+cos(iGlobalTime.x*3.0+50.0*uv.y));
        //vec4 color = texture2D(texture0, vec2(uv.x+xoffset , -1.0*(0.6 - uv.y+ yoffset)));
        //gl_FragColor = color;
        gl_FragColor = texture2D(texture0, vec2(uv.x, -uv.y));
    }
}
	]],
	uniform = {
		--{
			--name = "color",
			--type = "float4",
		--},
        {
            name = "resolution",
            type = "float2",
        },
        {
            name = "overlayColor",
            type = "float3",
        },
        {
            name = "iGlobalTime",
            type = "float2",
        },
	},
	texture = {
		"texture0",
	}
}
--gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
--s.color(1,0,0,1)	-- set shader color
s.resolution(800,600)
s.overlayColor(0.5,1,1)
s.iGlobalTime(1.0, 1.0)
local game = {}

local time = 0
function game.update()
    time = time + 0.01
    s.iGlobalTime(1.0,1.0)
end

function game.drawframe()
	ej.clear(0xff808080)	-- clear (0.5,0.5,0.5,1) gray
    shader.draw(TEXID, {
        --0,0,287,0,287,175,0,175,
        0,0,0,175,287,175,287,0,
		--88, 0, 88, 45, 147, 45, 147, 0,	-- texture coord
        -6400,-4800,-6400,4800,6400,4800,6400,-4800,
		---958, -580, -958, 860, 918, 860, 918, -580, -- screen coord, 16x pixel, (0,0) is the center of screen
	})

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

