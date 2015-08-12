-- This example show how user defined shader works

local ej = require "ejoy2d"
local fw = require "ejoy2d.framework"
local shader = require "ejoy2d.shader"
local ppm = require "ejoy2d.ppm"

local TEXID = 0
local TEX2 = 1
-- load ppm/pgm file into texture slot TEXID
ppm.texture(TEXID,fw.WorkDir.."examples/asset/water")
ppm.texture(TEX2,fw.WorkDir.."examples/asset/normal")

-- define a shader
local s = ej.define_shader {
	name = "NORMAL",
	fs = [[
//varying vec4 v_fragmentColor;
varying vec2 v_texcoord;
uniform vec2 iGlobalTime;

uniform sampler2D texture0;
uniform sampler2D u_normalMap;

vec3 waveNormal(vec2 p) {
    vec3 normal = texture2D(u_normalMap, p).xyz;
    normal = -1.0 + normal * 2.0;
    return normalize(normal);
}

void main() {
    float timeFactor = 0.2;
    float offsetFactor = 0.5;
    float refractionFactor = 0.5;
    
    // simple UV animation
    vec3 normal = waveNormal(v_texcoord + vec2(iGlobalTime.x * timeFactor, 0));
    
    // simple calculate refraction UV offset
    vec2 p = -1.0 + v_texcoord * 2.0;
    vec3 eyePos = vec3(0, 0, 100);
    vec3 inVec = normalize(vec3(p, 0) - eyePos);
    vec3 refractVec = refract(inVec, normal, refractionFactor);
    vec2 tmp = v_texcoord + refractVec.xy * offsetFactor;
    
    gl_FragColor = texture2D(texture0, tmp);// * v_fragmentColor;
}
	]],
	uniform = {
		--{
			--name = "color",
			--type = "float4",
		--},
        {
            name = "iGlobalTime",
            type = "float2",
        },
	},
	texture = {
		"texture0",
        "u_normalMap",
	}
}
--gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
--s.color(1,0,0,1)	-- set shader color
--s.resolution(800,600)
--s.overlayColor(0.5,1,1)
s.iGlobalTime(1.0, 1.0)
local game = {}

local time = 0
function game.update()
    time = time + 0.01
    if time > 1 then
        time = 0
    end
    s.iGlobalTime(time,1.0)
end

function game.drawframe()
	ej.clear(0xff808080)	-- clear (0.5,0.5,0.5,1) gray
    shader.texture(TEX2, 1)
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
