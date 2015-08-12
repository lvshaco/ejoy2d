local ej = require "ejoy2d"
local layout = require "util.layout"
local spritex = require "util.spritex"
local control = require "util.control"
local label = require "util.label"
local button = require "util.button"
local checkbox = require "util.checkbox"
local processbar = require "util.processbar"
local setmetatable = setmetatable
local assert = assert
local logger = require "ejoy2d.logger"

local ADAPT_NO = 0
local ADAPT_H  = 1
local ADAPT_W  = 2

local LO_LEFT = 1
local LO_TOP = 2
local LO_RIGHT = 4
local LO_BOTTOM = 8
local LO_CENTER = 16

local composite = control.new()
composite.__index = composite

local creator = {
    sprite = spritex,
    label = label,
    button = button,
    checkbox = checkbox,
    processbar = processbar,
}

local function __set_config(self, cfg)
    self.__layout_screen = cfg.screen
    self.__layoutx = cfg.xlayout
    self.__layouty = cfg.ylayout
    self.__layout_w = cfg.w
    self.__layout_h = cfg.h
    self.__layout_x = cfg.x
    self.__layout_y = cfg.y
    self.__layout_xscale = cfg.xscale
    self.__layout_yscale = cfg.yscale
end

function composite.new(packname, cfg)
    local self = control.init(composite, packname, cfg.export, "")
    local pspr = self.__sprite

    local ct = {}
    for _, g in ipairs(cfg) do
        cr = creator[g.uitype]
        assert(cr, "Invalid control type:"..g.uitype)
        local name = g.export
        local c
        -- pspr[name]? can fetch_by_index ?
        if type(g.param) == "table" then
            c = cr.new(nil, pspr[name], table.unpack(g.param))
        else
            c = cr.new(nil, pspr[name], g.param)
        end
        ct[name] = c
        __set_config(c, g)
    end
    self.__export = cfg.export
    self.__children = ct
    self.__last_touch = nil
    __set_config(self, cfg)

    local w, h = ej.screen()
    self:resize(w,h)
    return self
end

function composite:__ontouch(what, x, y)
    local hit = self.__sprite:test(x,y)
    if hit and hit ~= self.__sprite then
        local chit = self.__children[hit.name]
        if what == "BEGIN" then
            self.__last_touch = chit
            return chit:__ontouch_down(x,y)
        elseif what == "END" then
            self.__last_touch = nil
            return chit:__ontouch_up(x,y)
        elseif what == "MOVE" then
            return chit:__ontouch_in(x,y)
        end
    else
        if self.__last_touch then
            if what == "MOVE" then
                self.__last_touch:__ontouch_out(x,y)
            else
                self.__last_touch = nil
            end
        end
    end
end

function composite:resize(w,h)
    local pw,ph,x,y
    if self.__layout_screen then
        pw,ph = layout.fixr(w),layout.fixr(h) -- screen or self
    else
        pw,ph = self.__layout_w,self.__layout_h
    end
    for _, c in pairs(self.__children) do
        if c.__layoutx == 'l' then
            x = c.__layout_x
        elseif c.__layoutx == 'r' then
            x = self.__layout_w-c.__layout_x-c.__layout_w
            x = pw - c.__layout_w - x
        elseif c.__layoutx == 'c' then
            x = self.__layout_w//2 - c.__layout_x - c.__layout_w//2
            x = pw//2 - c.__layout_w//2 - x
        else
            error("Invalid layoutx:"..c.__layoutx)
        end
        if c.__layouty == 't' then
            y = c.__layout_y
        elseif c.__layouty == 'b' then
            y = self.__layout_h-c.__layout_y-c.__layout_h
            y = ph - c.__layout_h - y
        elseif c.__layouty == 'c' then
            y = self.__layout_h//2 - c.__layout_y - c.__layout_h//2
            y = ph//2 - c.__layout_h//2 - y 
        else
            error("Invalid layouty:"..c.__layouty)
        end
        assert(c.__layout_xscale == c.__layout_yscale)
        c:anchorpoint(0,0)
        c:ps(x,y,layout.fixr(c.__layout_xscale))
        --c.__sprite:ps(x,y,c.__layout_xscale)
    end
    self:anchorpoint(0,0)
    -- todo ?
    self:ps(0,0,1,'l','t')
end

function composite:update()
    control.update(self)
    for _,c in pairs(self.__children) do
        c:update()
    end
end

function composite:child(name)
    return self.__children[self.__export..'_'..name]
end

return composite
