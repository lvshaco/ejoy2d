local control = require "ui.control"
local spritex = require "ex.spritex"

local panel = control.new()
panel.__index = panel

function panel.new(packname, spr)
    local cfg
    if type(spr) == 'table' then -- spr is the config
        cfg = spr
        spr = cfg.export
    end
    local self = control.construct(panel, packname, spr)
    self.__touch_current = false
    if cfg then
        self:init(cfg)
    end
    return self
end

local function __set_layout(c, cfg)
    local pos
    if cfg.init then
        pos = cfg.init.pos
    end
    c.__layoutx = cfg.xlayout
    c.__layouty = cfg.ylayout
    if pos then
        c.__layout_x = pos[1]
        c.__layout_y = pos[2]
    else
        c.__layout_x = 0
        c.__layout_y = 0
    end
    c.__layout_w = cfg.w
    c.__layout_h = cfg.h
    --c.__name = cfg.export -- just for debug
end

function panel:init(cfg)
    local parent = self.__sprite
    local mod, c, name
    local children = {}
    for _, sub in ipairs(cfg) do
        if sub.uitype == 'sprite' then
            mod = spritex
        else
            mod = require('ui.'..sub.uitype)
        end
        name = sub.export
        -- todo parent[name]? can fetch_by_index ?
        c = mod.new(nil, parent[name])
        if sub.uitype == 'panel' then
            c:init(sub)
        else
            if sub.init0 then
                c:init(sub.init0)
            end
            if sub.init then
                c:init(sub.init)
            end
        end
        children[name] = c
        __set_layout(c, sub)
        c:anchorpoint(0,0) -- todo: it is suitable ?
    end
    self.__export = cfg.export
    self.__children = children

    if cfg.init0 then
        control.init(self, cfg.init0)
    end
    if cfg.init then
        control.init(self, cfg.init)
    end
    __set_layout(self, cfg)
    self:anchorpoint(0,0) -- todo: it is suitable ?
end

function panel:reset_scale9(w,h)
    if self.__sprite.bg then
        control.reset_scale9(self, w,h, self.__sprite.bg)
    end
end

function panel:resize(w,h)
    self:reset_scale9(w,h)
    local scalex = w/self.__layout_w
    local scaley = h/self.__layout_h
    for _, c in pairs(self.__children) do
        if c.__layoutx == 'l' then
            x = c.__layout_x
        elseif c.__layoutx == 'r' then
            x = self.__layout_w-c.__layout_x-c.__layout_w
            x = w - c.__layout_w - x
        elseif c.__layoutx == 'c' then
            x = self.__layout_w//2 - c.__layout_x - c.__layout_w//2
            x = w//2 - c.__layout_w//2 - x
        else
            error("Invalid layoutx:"..c.__layoutx)
        end
        if c.__layouty == 't' then
            y = c.__layout_y
        elseif c.__layouty == 'b' then
            y = self.__layout_h-c.__layout_y-c.__layout_h
            y = h - c.__layout_h - y
        elseif c.__layouty == 'c' then
            y = self.__layout_h//2 - c.__layout_y - c.__layout_h//2
            y = h//2 - c.__layout_h//2 - y 
        else
            error("Invalid layouty:"..c.__layouty)
        end
        -- todo: will reset pos to initialize layout
        c:anchorpoint(0,0)
        c:pos(x,y) 
    end
end

function panel:__touchdown(x,y,hit)
    if hit ~= self.__sprite then
        local child = self.__children[hit.name]
        self.__touch_current = child
        child:__ontouchdown(x,y)
    end
end

function panel:__touchup(x,y)
    if self.__touch_current then
        self.__touch_current:__ontouchup(x,y)
        self.__touch_current = false
    end
end

function panel:__touchmove(x,y)
    if self.__touch_current then
        self.__touch_current:__ontouchmove(x,y)
    end
end

function panel:__touchout(x,y)
    if self.__touch_current then
        self.__touch_current:__ontouchout(x,y)
    end
end

function panel:update()
    control.update(self)
    for _,c in pairs(self.__children) do
        c:update()
    end
end

function panel:child(name)
    return self.__children[name]
end

return panel
