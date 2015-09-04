-- This example show how user defined shader works

local ej = require "ejoy2d"
local fw = require "ejoy2d.framework"
local pack = require "ejoy2d.simplepackage"
local shader = require "ejoy2d.shader"
local ppm = require "ejoy2d.ppm"

pack.load {
    pattern = fw.WorkDir..[[examples/asset/?]],
    "diffuse", "normal"
}
local obj = ej.sprite("diffuse", 0)
local obj2 = ej.sprite("normal", 0)

-- define a shader
local s = ej.define_shader {
	name = "NORMAL1",
	fs = [[
varying vec2 v_texcoord;
uniform sampler2D texture0;
uniform sampler2D tex_normal;
uniform vec4 lightcolor;
uniform vec3 lightpos;
uniform vec3 falloff;
uniform vec3 ambient;
uniform vec2 resolution;

void main() {
    vec4 DiffuseColor = texture2D(texture0, v_texcoord);
    
    // 法线贴图的法线数据
    vec3 normal = texture2D(tex_normal, v_texcoord).rgb;
    // 将法线贴图里的rgb数据转换成真正的法线数据，并归一化
     vec3 N = normalize(normal * 2.0 - 1.0);
    // vec3 N = normal; // todo: ?? need normalize
    //2d游戏中计算这个光的方向比较简单，直接算屏幕里的位置就行了
    // vec3 ldir = vec3(lightpos.xy - (gl_FragCoord.xy / resolution.xy), lightpos.z);
    vec3 ldir = vec3(lightpos.xy - v_texcoord, lightpos.z);
    //计算光的长度，用于计算光的衰减
    float D = length(ldir);
    //归一化光的方向
    vec3 L = normalize(ldir);
    //计算光的衰减参数
    float Attenuation = 1.0 / ( falloff.x + (falloff.y*D) + (falloff.z*D*D) );
     
    //计算法线对于光照的影响
    vec3 Diffuse = (lightcolor.rgb * lightcolor.a) * max(dot(N, L), 0.0);
    //计算环境光加上光线的衰减
    vec3 Intensity = ambient + Diffuse * Attenuation;
    //和原始贴图数据进行计算混合
    gl_FragColor = vec4(DiffuseColor.rgb * Intensity, DiffuseColor.a);
}
	]],
	uniform = {
        {
            name = "lightcolor",
            type = "float4",
        },
        {
            name = "lightpos",
            type = "float3",
        },
        {
            name = "falloff",
            type = "float3",
        },
        {
            name = "ambient",
            type = "float3",
        },
        {
            name = "resolution",
            type = "float2";
        },
	},
	texture = {
		"texture0",
        "tex_normal",
	}
}
s.resolution(800,600)
s.lightcolor(1,1,1,1)	-- set shader color
s.lightpos(0.5,0.5,0)
s.falloff(0.5,0.5,0.5)--(1.0,2.1,2.1)
s.ambient(0.6,0.6,0.6)

obj.program = "NORMAL1"
shader.texture(1, 1)
local game = {}

local time = 0
function game.update()
    time = time + 0.01
    if time > 1 then
        time = 0
    end
    --s.lightpos(time,0.8,0)
end

function game.drawframe()
	ej.clear(0xff808080)	-- clear (0.5,0.5,0.5,1) gray
    

    --shader.draw(TEXID, {
        ----0,0,0,175,287,175,287,0,
        --0,0,0,386, 272,386, 272,0,
        ---2176,-3088,-2176,3088,2176,3088,2176,-3088,
    --})

    obj:draw()
    --obj2:draw()
end

function game.touch(what, x, y)
    if what == "MOVE" then
        px = x/800
        py = 1-y/600 
        s.lightpos(px,py,0)
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
