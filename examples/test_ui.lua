local ej = require "ejoy2d"
local fw = require "ejoy2d.framework"
local pack = require "ejoy2d.simplepackage"
local matrix = require "ejoy2d.matrix"
local logger = require "ejoy2d.logger"
local layout = require "ex.layout"
local spritex = require "ex.spritex"
local coco = require "ex.coco"
local layer = require "ex.layer"
local tween = require "ex.tween"
local action = require "ex.action"
local label = require "ui.label"
local button = require "ui.button"
local checkbox = require "ui.checkbox"
local progressbar = require "ui.progressbar"
local sliderbar = require "ui.sliderbar"
local listview = require "ui.listview"
local panel = require "ui.panel"
local uiimage_uc = require "examples.asset.uiimage_uc"

local t1 = os.time()
pack.load {
    pattern = fw.WorkDir..[[examples/asset/?]],
    "uiimage", "image"
}
local t2 = os.time()
logger.log("pack.load use time:"..(t2-t1))
logger.log(fw.WorkDir)

local sw, sh = ej.screen()
layout.init(sw, sh, "H")

local function frame2ms(x)
    return x*1000/30
end
local F = frame2ms
local L

local T = {}
function T.showui()
    --local max = 0.8
    --local min = 0.78
    --sx = spritex.new('uiimage','effect_active_char.png')
    --local x = layout.pointx(0.5)
    --local y = layout.pointy(0.5)
    --sx:ps(x,y)

    ----sx:action(actionscale.new(0.5,1.0,6000,af.linear))
    --sx:action(actionsequence.new(
    --    actiongroup.new(
    --        actioncolor.new(0x00ffffff,0xffffffff,F(6),af.linear),--af.linear),
    --        actionscale.new(0.1,max,F(6),af.linear)--af.linear)
    --    ),
    --    actionscale.new(max,min,F(3),af.linear),--af.linear),
    --    actionscale.new(min,max,F(3),af.linear)
    --))
    --L:add(2, sx)
end

function T.button()
    local l1 = label.new('uiimage', 'node_Text_1')
    l1:text('label')
    l1:pos(100, 50)
    
    local b1 = button.new('uiimage', 'node_Button_1')
    b1:text('btn1')
    b1:pos(100,100)
    b1:scale(2)
    b1:touch_event('down', function(self,x,y)
        l1:text('b1 down')
    end)
    b1:touch_event('up', function(self,x,y)
        l1:text('b1 up')
    end)

    local c1 = checkbox.new('uiimage', 'node_CheckBox_1')
    c1:pos(200, 100)
    c1:touch_event('down', function()
        l1:text('c1 state:'..tostring(c1.__selected))
    end)

    local p1 = progressbar.new('uiimage', 'node_LoadingBar_1', 100)
    p1:pos(300, 300)
    p1:scale(2)
    --p1:rot(180)
    p1.update = function(self)
        p1:degree(p1.__degree+1)
        spritex.update(p1)
    end

    local s1 = sliderbar.new('uiimage', 'node_Slider_1', 100)
    --s1:anchorpoint(0,0)
    s1:pos(300, 400)
    s1:scale(2)
    --s1:rot(180)
    s1:update()
    --print ("==", s1.__sprite:aabb())
    --print ("==", s1.__sprite.back:aabb())
    --print ("==", s1.__sprite.back:world_pos())
    --print (s1.__sprite.degree:aabb())
    s1:touch_event('degree', function()
        l1:text('s1 degree:'..s1.__degree)
    end)
    --s1:enable(false)
    L:add(2,b1)
    L:add(2,l1)
    L:add(2,c1)
    L:add(2,p1)
    L:add(2,s1)
end

function T.panel()
    local c1 = panel.new('uiimage', uiimage_uc.win)
    c1:pos(100,100)
    --c1:scale(2)
    c1:child('Button_1'):touch_event('up', function()
        c1:resize(ej.screen())
        c1:pos(0,0)
    end)
    L:add(2,c1)
end

function T.test()
    local s = spritex.new('image',0)
    s:anchorpoint(0,0)
    L:add(2,s)
end

for i=1,7 do
    T['test'..i] = function() end
end

local function init()
    L = layer.new()
    L:bind(1, {}, ipairs, layer.ALL)
    L:bind(2, {}, ipairs, layer.UPDATE|layer.DRAW|layer.TOUCH)
    L:bind(3, coco:new(), ipairs, layer.UPDATE|layer.TOUCHLAST)

    --T.button()
    local lv = listview.new('uiimage', 'node_ListView_1', 11)
    lv:anchorpoint(1,0.5)
    lv:pos(layout.pointx(1),layout.pointy(0.8))
    lv:scale(1.5)
    lv:gap(3)
    local function __up(self,x,y)
        L:clr(2)
        local name = self:get_text()
        T[name]()
    end
    local item 
    for k, v in pairs(T) do
        item = button.new('uiimage', 'node_Button_1')
        item:text(k)
        item:touch_event('up', __up)
        lv:insert(item)
    end
    L:add(1,lv)
end

init()
--------------------------------------------

local game = {}

function game.update()
    ej.elapsed = ej.elapsed+1
    L:update()
end

function game.drawframe()
	ej.clear(0xff000000)
    L:draw()
end

function game.touch(what, x, y)
    L:touch(what,x,y)
end

function game.on_resize(w,h)
    logger.log("game on reisze",w,h) 
    layout.resize(w,h)
    L:resize(w,h)
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
