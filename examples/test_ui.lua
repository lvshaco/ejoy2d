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
--local F = frame2ms
local F = function(x) return x end
local L

local T = {}
function T.showui()
    local max = 0.8
    local min = 0.78
    local sx = spritex.new('uiimage',103)
    local x = layout.pointx(0.5)
    local y = layout.pointy(0.5)
    sx:anchorpoint(0.5,0.5)
    sx:pos(x,y)
    sx:reset_scale9(600,400)
    --sx:scale(0.8)--0.68333333333333)
    --sx:action(action.scale(tween.new(0.1,1,F(6),tween.f.linear)))
    sx:action(action.sequence(
        action.group(
            action.color(tween.new({a=0,r=0xff,g=0xff,b=0xff},{a=0xff},F(6),tween.f.linear)),
            action.scale(tween.new(0.1,max,F(6),tween.f.linear))
        ),
        action.scale(tween.new(max,min,F(3),tween.f.linear)),
        action.scale(tween.new(min,max,F(3),tween.f.linear))
        )
    )
    L:add(2, sx)
end

function T.button()
    local l1 = label.new('uiimage', 'node_Text_1')
    l1:text('label')
    l1:pos(100, 50)
    
    local b1 = button.new('uiimage', 'node_Button_1')
    b1:reset_scale9(80,36)
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
    local c1 = panel.new('uiimage', uiimage_uc.win_Panel_1)
    c1:pos(0,0)
    --c1:scale(2)
    c1:child('Button_1'):touch_event('up', function()
        c1:resize(ej.screen())
        c1:pos(0,0)
    end)
    L:add(2,c1)
end

function T.panelnoback()
    local c1 = panel.new('uiimage', uiimage_uc.winnoback_Panel_1)
    c1:pos(0,0)
    --c1:scale(2)
    c1:child('Button_1'):touch_event('up', function()
        c1:resize(ej.screen())
        c1:pos(0,0)
    end)
    L:add(2,c1)
end

function T.test()
    --local b = button.new('uiimage', 'nodescale9_Button_1')
    --b:anchorpoint(0,0)
    --b:reset_scale9(100,100)
    --L:add(2,b)
end

--{ tex = 1, src = {890,264,930,264,930,304,890,304}, screen = {0,0,640,0,640,640,0,640} },
--{ tex = 1, src = {890,264,903,264,903,277,890,277}, screen = {0,0,208,0,208,208,0,208} },

function T.scale9()
    local s1 = panel.new('uiimage', uiimage_uc.win9scale_Panel_2)
    --local s1 = spritex.new('uiimage', 41)
    s1:anchorpoint(0,0)
    s1:pos(150,100)
    local scale =1
    local w, h = 200,300
    s1:touch_event('up', function()
        w = w-10
        h = h-10
        s1:resize(w,h)
    end)
    --s1:child('bg'):touch_event('up', function()
    --    s1:scale(scale)
    --end)
    local s = spritex.new('image',0)
    s:anchorpoint(0,0)
    s:pos(150,100)
    L:add(2,s)
    L:add(2,s1)
end

--for i=1,6 do
--    T['test'..i] = function() end
--end

local function init()
    L = layer.new()
    L:bind(1, {}, ipairs, layer.ALL)
    L:bind(2, {}, ipairs, layer.UPDATE|layer.DRAW|layer.TOUCH)
    L:bind(3, coco:new(), ipairs, layer.UPDATE|layer.TOUCHLAST)

    T.showui()
    local lv = listview.new('uiimage', 'node_ListView_1', 11)
    lv:reset_scale9(100,200)
    lv:anchorpoint(1,0.5)
    lv:pos(layout.pointx(1),layout.pointy(0.5))
    lv:scale(1)
    lv:gap(3)
    local function __up(self,x,y)
        L:clr(2)
        local name = self:get_text()
        T[name]()
    end
    local item 
    for k, v in pairs(T) do
        item = button.new('uiimage', 'node_Button_1')
        item:reset_scale9(80,36)
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
    L:update(1)
end

function game.drawframe()
	ej.clear(0xffa0a0a0)
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
