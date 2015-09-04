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
local obj2 = ej.sprite("diffuse",0)

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
uniform vec2 content;
void main() {
    vec4 texcolor = texture2D(texture0, v_texcoord);
    
    // 法线贴图的法线数据
    vec3 normal = texture2D(tex_normal, v_texcoord).rgb;
    // 将法线贴图里的rgb数据转换成真正的法线数据，并归一化
     vec3 N = normalize(normal * 2.0 - 1.0);
     N.y = -N.y;
    // vec3 N = normal; // todo: ?? need normalize
    //2d游戏中计算这个光的方向比较简单，直接算屏幕里的位置就行了
    //vec3 ldir = vec3(lightpos.xy - (gl_FragCoord.xy / resolution.xy), lightpos.z);
    //vec3 ldir = vec3(lightpos.xy - v_texcoord, lightpos.z);
    //vec3 curpixel = vec3(content.x*v_texcoord.x, (1.0-v_texcoord.y)*content.y,0.0);
    vec3 curpixel = vec3(gl_FragCoord.x, 600.0-gl_FragCoord.y, 0);
    vec3 ldir = lightpos-curpixel;
    float D = length(ldir);
    ldir = normalize(ldir);
    //计算光的长度，用于计算光的衰减
    //归一化光的方向
    vec3 L = normalize(ldir);
    //计算光的衰减参数
    //float falloffTerm = 1.0 / ( falloff.x + (falloff.y*D) + (falloff.z*D*D) );
    //计算法线对于光照的影响
    vec3 Diffuse =  max(dot(N, L), 0.0) * (lightcolor.rgb * lightcolor.a);
    //计算环境光加上光线的衰减

    float u_cutoffRadius = 200.0;
    float u_halfRadius = 0.5;
    float intercept = u_cutoffRadius * u_halfRadius;
    float dx_1 = 0.5 / intercept;
    float dx_2 = 0.5 / (u_cutoffRadius - intercept);
    float offset = 0.5 + intercept * dx_2;
    float lightDist = D;
    float falloffTermNear = clamp((1.0 - lightDist * dx_1), 0.0, 1.0);
    float falloffTermFar  = clamp((offset - lightDist * dx_2), 0.0, 1.0);
    float falloffSelect = step(intercept, lightDist);
    //float falloffTerm = (1.0 - falloffSelect) * falloffTermNear + falloffSelect * falloffTermFar;
    float falloffTerm = 1.0-(D-lightpos.z)/u_cutoffRadius;
    float brightness=3.0;
    vec3 Intensity = ambient + Diffuse*brightness *falloffTerm;
    //和原始贴图数据进行计算混合
    gl_FragColor = vec4(texcolor.rgb * Intensity, texcolor.a);
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
        {
            name = "content",
            type = "float2";
        },
	},
	texture = {
		"texture0",
        "tex_normal",
	}
}
obj.program = "NORMAL1"
obj.material:resolution(800,600)
obj.material:lightcolor(1,1,1,1)	-- set shader color
obj.material:lightpos(0,0,50)
obj.material:falloff(0.5,0.5,0.5)--(1.0,2.1,2.1)
obj.material:ambient(0.0,0.0,0.0)
local x,y,x2,y2=obj:aabb()
obj.material:content(x2-x,y2-y)
print (x,y,x2-x,y2-y)
shader.texture(1, 1)
obj:ps(100, 100)
--obj:sr(2,2)

obj2.program = "NORMAL1"
obj2.material:resolution(800,600)
obj2.material:lightcolor(1,1,1,1)	-- set shader color
obj2.material:lightpos(0,0,50)
obj2.material:falloff(0.5,0.5,0.5)--(1.0,2.1,2.1)
obj2.material:ambient(0.0,0.0,0.0)--(1.0,1.0,1.0)
local x,y,x2,y2=obj2:aabb()
obj2.material:content(x2-x,y2-y)
print (x,y,x2-x,y2-y)
shader.texture(1, 1)
obj2:ps(250, 250)
--obj2:sr(2,2)

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
	ej.clear(0xff000000)	-- clear (0.5,0.5,0.5,1) gray
    
    --shader.draw(TEXID, {
        ----0,0,0,175,287,175,287,0,
        --0,0,0,386, 272,386, 272,0,
        ---2176,-3088,-2176,3088,2176,3088,2176,-3088,
    --})

    obj:draw()
    obj2:draw()
    for i=0,10 do
        --obj:ps(i*10,i*100)
        --obj:draw()
    end
end

function game.touch(what, x, y)
--    if what == "MOVE" then
        local px = x/800
        local py = 1-y/600 
        local px,py,_,_ = obj:aabb()
        px = x-px
        py = y-py
        --obj.material:lightpos(px,py,50)
        obj.material:lightpos(x,y,50)
        local px,py,_,_ = obj2:aabb()
        px = x-px
        py = y-py
        --obj2.material:lightpos(px,py,50)
        obj2.material:lightpos(x,y,50)
        --s.lightpos(px,py,50)
 --   end
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
