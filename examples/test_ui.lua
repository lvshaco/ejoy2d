local ej = require "ejoy2d"
local fw = require "ejoy2d.framework"
local pack = require "ejoy2d.simplepackage"
local layout = require "util.layout"
local logger = require "ejoy2d.logger"
local spritex = require "util.spritex"
local matrix = require "ejoy2d.matrix"
local coco = require "util.coco"
local layer = require "util.layer"
local listview = require "util.listview"
local button = require "util.button"

local t1 = os.time()
pack.load {
    pattern = fw.WorkDir..[[test/asset/?]],
    "ui_test"
}
local t2 = os.time()
logger.log("pack.load use time:"..(t2-t1))
logger.log(fw.WorkDir)

layout.init(1024, 740, "H")

--------------------------------------------
local spritex = require "util.spritex"
local af = require "util.actionformula"
local actionsequence = require "util.actionsequence"
local actiongroup = require "util.actiongroup"
local actioncolor = require "util.actioncolor"
local actionscale = require "util.actionscale"
local actionpos = require "util.actionpos"
local function frame2ms(x)
    return x*1000/30
end
local F = frame2ms
local L

local T = {}
function T.showui()
    local max = 0.8
    local min = 0.78
    sx = spritex.new('ui_test','effect_active_char.png')
    local x = layout.pointx(0.5)
    local y = layout.pointy(0.5)
    sx:ps(x,y)

    --sx:action(actionscale.new(0.5,1.0,6000,af.linear))
    sx:action(actionsequence.new(
        actiongroup.new(
            actioncolor.new(0x00ffffff,0xffffffff,F(6),af.linear),--af.linear),
            actionscale.new(0.1,max,F(6),af.linear)--af.linear)
        ),
        actionscale.new(max,min,F(3),af.linear),--af.linear),
        actionscale.new(min,max,F(3),af.linear)
    ))
    L:add(2, sx)
end

for i=1,10 do
    T['test'..i] = function() end
end

local function init()
    L = layer.new()
    L:bind(1, {}, ipairs, layer.ALL)
    L:bind(2, {}, ipairs, layer.UPDATE|layer.DRAW|layer.TOUCH)
    L:bind(3, coco:new(), ipairs, layer.UPDATE|layer.TOUCHLAST)

    local lv = listview.new('ui_test', 'node_listview', 11)
    lv:anchorpoint(1,0.5)
    lv:ps(layout.pointx(1),layout.pointy(0.5),0.5)
    lv:setgap(3)
    local function __up(self,x,y)
        L:clr(2)
        local name = self:get_text()
        T[name]()
    end
    local item 
    for k, v in pairs(T) do
        item = button.new('ui_test', 'node_listview_item', k)
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
