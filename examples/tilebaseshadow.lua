local ej = require "ejoy2d"
local fw = require "ejoy2d.framework"
local pack = require "ejoy2d.simplepackage"
local geo = require "ejoy2d.geometry"
local tbl = require "util.tbl"

pack.load {
    pattern = fw.WorkDir..[[examples/asset/?]],
    "tilebase",
}

local W, H = fw.screen()

local map_data = {
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
1,0,0,1,0,1,0,0,0,0,0,1,0,0,1,
1,1,0,0,0,0,0,1,1,0,0,1,0,0,1,
1,0,0,1,0,0,0,1,1,0,0,1,0,1,1,
1,0,0,0,0,1,0,0,0,0,0,0,0,0,1,
1,1,1,0,1,1,0,0,0,0,0,0,0,0,1,
1,0,0,0,0,0,0,1,1,1,0,0,1,0,1,
1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,
1,0,0,0,1,1,1,1,0,0,0,0,1,0,1,
1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,
1,0,0,0,1,0,0,1,0,0,0,0,0,0,1,
1,0,0,1,0,0,0,0,0,0,0,1,1,1,1,
1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,
1,1,0,0,0,0,0,0,0,0,0,1,0,0,1,
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
}

local light =  {
    __spr = false,
    __x = false,
    __y = false,
}

function light:init()
    self.__spr = ej.sprite("tilebase", "light.png")
    self.__x = 13
    self.__y = 2 
end

function light:get_pos()
    return self.__x*40+20, self.__y*40+20
end

function light:draw()
    self.__spr:ps(self.__x*40, self.__y*40)
    self.__spr:draw()
end

local tile = {}
tile.__index = tile
    
function tile.new()
    self = {
        __spr = ej.sprite("tilebase", "block.png"),
        __x = false,
        __y = false,
    }
    return setmetatable(self, tile)
end

function tile:position(x,y)
    self.__x = x
    self.__y = y
    self.__spr:ps(x*40,y*40)
end

function tile:draw()
    self.__spr:draw()
end

local map = {
    __tiles = {},
}

function map:init()
    local x, y
    local t
    for i, v in ipairs(map_data) do
        if v == 1 then
            x = (i-1)%15
            y = (i-1)//15
            t = tile.new()
            t:position(x,y)
        else
            t = false
        end
        self.__tiles[i] = t
    end
end

function map:draw()
    for i, v in ipairs(self.__tiles) do
        if v then
            v:draw()
        end
    end
end

function map:draw_grid()
    local y = 0
    while y < H do
        geo.line(0, y, W, y, 0xffffff00)
        y = y + 40
    end
    local x = 0
    while x < W do
        geo.line(x, 0, x, H, 0xffffff00)
        x = x + 40
    end
end

local lines = {}
local function line_dump()
    for _, v in ipairs(lines) do
        print (_, string.format("(%f,%f)->(%f,%f)", v.x1,v.y1, v.x2,v.y2))
    end
end

local function light_face()
    local l
    local near
    local x, y
    for i, t in ipairs(map.__tiles) do
        if t then
            l = nil
            x,y = t.__x, t.__y
            if light.__x > x then -- right
                near = map.__tiles[y*15+x+1+1] 
                if not near then
                    l = {}
                    l.x1 = x+1
                    l.y1 = y
                    l.x2 = x+1
                    l.y2 = y+1
                end
            elseif light.__x < x then -- left
                near = map.__tiles[y*15+x-1+1]
                if not near then
                    l = {}
                    l.x1 = x
                    l.y1 = y+1
                    l.x2 = x
                    l.y2 = y
                end
            end
            if l then
                table.insert(lines, l)
                l = nil
            end
            if light.__y > y then -- bottom
                near = map.__tiles[(y+1)*15+x+1]
                if not near then
                    l = {}
                    l.x1 = x+1
                    l.y1 = y+1
                    l.x2 = x
                    l.y2 = y+1
                end
            elseif light.__y < y then -- top
                near = map.__tiles[(y-1)*15+x+1]
                if not near then
                    l = {}
                    l.x1 = x
                    l.y1 = y
                    l.x2 = x+1
                    l.y2 = y
                end
            end
            if l then
                table.insert(lines, l)
            end
        end
    end
end

local function locate_next(l)
    for _, v in ipairs(lines) do
        if v ~= l then
            if l.x2 == v.x1 and l.y2 == v.y1 then
                return v
            end
        end
    end
end

local function line_intersection(l1, l2)
    -- 如果分母为0 则平行或共线, 不相交
    local denominator = (l1.y2 - l1.y1)*(l2.x2 - l2.x1) - 
                        (l1.x1 - l1.x2)*(l2.y1 - l2.y2);
    if denominator== 0 then
        return
    end
    local x = ( (l1.x2 - l1.x1) * (l2.x2 - l2.x1) * (l2.y1 - l1.y1) 
                + (l1.y2 - l1.y1) * (l2.x2 - l2.x1) * l1.x1 
                - (l2.y2 - l2.y1) * (l1.x2 - l1.x1) * l2.x1 ) / denominator ;
    local y = -( (l1.y2 - l1.y1) * (l2.y2 - l2.y1) * (l2.x1 - l1.x1) 
                + (l1.x2 - l1.x1) * (l2.y2 - l2.y1) * l1.y1 
                - (l2.x2 - l2.x1) * (l1.y2 - l1.y1) * l2.y1 ) / denominator;
--print (string.format("intersection: (%f,%f)->(%f,%f), (%f,%f)", 
            --l2.x1, l2.y1, l2.x2, l2.y2, x,y))
    if (x - l2.x1) * (x - l2.x2) <= 1e-10 and 
       (y - l2.y1) * (y - l2.y2) <= 1e-10 and -- 交点在l2上
       (l1.x1-l1.x2) * (l1.x2-x) >= 1e-10 and 
       (l1.y1-l1.y2) * (l1.y2-y) >= 1e-10 then -- 交点在l1的方向上
        return x, y
    end
end

local function line_init()
    lines = {}
    light_face()

    local lx, ly = light:get_pos()
    for _, v in ipairs(lines) do
        local cx, cy = (v.x2-v.x1)*40//2 + v.x1*40, (v.y2-v.y1)*40//2 + v.y1*40
        v.distance = (cx-lx)*(cx-lx) + (cy-ly)*(cy-ly)
    end
    for _, v in ipairs(lines) do
        if not v.next then
            local lnext = locate_next(v)
            if lnext then
                v.next = lnext
                assert(lnext.prev == nil)
                lnext.prev = v 
            end
        end
    end
    
    table.sort(lines, function (l1,l2)
        return l1.distance < l2.distance
    end)

    for _, v in ipairs(lines) do
        if not v.next then
            --print (_, string.format("next (%f,%f)->(%f,%f)", v.x1,v.y1,v.x2,v.y2))
            local ray = {x1=light.__x+0.5, y1=light.__y+0.5, x2= v.x2, y2=v.y2}
            for _, v2 in ipairs(lines) do
                if v2 ~= v then
                    local x, y = line_intersection(ray, v2)
                    if x then
                        --print (x,y)
                        local lnew = {x1=v.x2, y1=v.y2, x2=x,y2=y, 
                            prev=v, next=v2, isray = true}
                        v.next = lnew
                        v2.x1 = x
                        v2.y1 = y
                        v2.prev = lnew
                        break
                    end
                end
            end
        end
        if not v.prev then
            --print (_, string.format("prev (%f,%f)->(%f,%f)", v.x1,v.y1,v.x2,v.y2))
            local ray = {x1=light.__x+0.5, y1=light.__y+0.5, x2= v.x1, y2=v.y1}
            for _, v2 in ipairs(lines) do
                if v2 ~= v then
                    local x, y = line_intersection(ray, v2)
                    if x then
                        --print (x,y)
                        local lnew = {x1=x, y1=y, x2=v.x1,y2=v.y1, 
                            prev=v2, next=v, isray = true}
                        v.prev = lnew
                        v2.x2 = x
                        v2.y2 = y
                        v2.next = lnew
                        break
                    end
                end
            end
        end
    end

    local tmp = {}
    if #lines > 0 then
        local first = lines[1]
        table.insert(tmp, first)
        first.select = true
        local cur = first.next
        while cur and not cur.select do --cur ~= first do
            table.insert(tmp, cur)
            cur.select = true
            cur = cur.next
        end
    end
    lines = tmp
    --tbl.print(lines, "lines")
    --line_dump()
end

local function line_draw()
    for i, l in ipairs(lines) do
        geo.line(l.x1*40, l.y1*40, l.x2*40, l.y2*40, 0xffff0000)
    end
    local lx, ly = light:get_pos()
    for _, v in ipairs(lines) do
        geo.polygon({lx,ly, v.x1*40,v.y1*40, v.x2*40,v.y2*40}, 0xffffff00)
    end
end

light:init()
map:init()
line_init()

local game = {}
local screencoord = { x = 512, y = 384, scale = 1.2 }

function game.update()
end

function game.drawframe()
	ej.clear(0xff808080)	-- clear (0.5,0.5,0.5,1) gray
    map:draw()
map:draw_grid()
    light:draw()
    line_draw()
end

function game.touch(what, x, y)
    if what == "BEGIN" then
        light.__x = x//40
        light.__y = y//40
        line_init()
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

function game.resize(w,h)
end

ej.start(game)


