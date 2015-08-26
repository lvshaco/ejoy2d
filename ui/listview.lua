local control = require "ui.control"
local scale9 = require "ex.scale9"

local listview = control.new()
listview.__index = listview

function listview.new(packname, spr)
    local self = control.construct(listview, packname, spr)
    self.__list = {}
    self.__hititem = nil
    
    self.__bind_last = 0
    self.__listold = {}
    local i=1
    local item
    while true do
        item = self.__sprite['item'..i]
        if item then
            self.__listold[i] = item
        else break end
        i=i+1
    end
    self.__draw_count = i-1
    self.__draw_start = 1
    self.__gap = 5
    self.__dragoff = 0
    return self
end

function listview:gap(n)
    self.__gap = n
end

local function insert_sx(self, sx, pos)
    if pos < self.__draw_start or 
       pos >= self.__draw_start+self.__draw_count then
        return
    end
    local gap = self.__gap
    local offy
    if pos > 1 then
        local s = self.__sprite['item'..(pos-1)]
        local _,_,_,y = s:aabb()
        offy = y+gap
    else
        offy = 0
    end
    if self.__bind_last < self.__draw_count then
        self.__bind_last = self.__bind_last+1
    end
    for i=self.__bind_last,pos+1,-1 do
        self.__sprite['item'..i] = self.__sprite['item'..(i-1)]
    end
    self.__sprite['item'..pos] = sx.__sprite
    for i=pos, self.__bind_last do
        local s = self.__sprite['item'..i]
        s:ps(0, offy)
        local _,_,_,y = s:aabb()
        offy = offy+y+gap
    end
end

function listview:insert(sx, pos)
    pos = pos or #self.__list+1
    table.insert(self.__list, pos, sx)
    insert_sx(self, sx, pos)
end

local function refresh_drag(self, dragy)  
    self.__dragoff = self.__dragoff + dragy 
    local gap = self.__gap
    local offy = self.__dragoff
    local start, starty, sx
    for i=1, #self.__list do -- todo half find
        sx = self.__list[i]
        offy = offy+(sx.__h)+gap
        if offy<0 then
            start = i+1
            starty = offy
        end
    end
    if not start then
        start = 1
        starty = self.__dragoff
    end
    local last = start+self.__draw_count-1 
    if last > #self.__list then
        last = #self.__list
    end
    local cnt = last-start+1
    for i=1,cnt do
        sx = self.__list[i+start-1]
        sx.__sprite:ps(0, starty)
        self.__sprite['item'..i] = sx.__sprite
        starty = starty+sx.__h+gap
    end
    for i=cnt+1,self.__draw_count do
        self.__sprite['item'..i] = self.__listold[i]
    end
    self.__draw_start = start
end

local function hititem(self, name)
    local a, b = string.byte(name,5,#name)
    if a >=49 and a<=57 then
        local id = a-48
        if b then
            id = id*10 + b-48
        end
        id = self.__draw_start+id-1
        return self.__list[id]
    end
end

function listview:__touchdown(x,y,hit)
    if hit.name then
        self.__drag = y
        local item = hititem(self, hit.name)
        if item then
            item:__ontouchdown(x,y)
            self.__hititem = item
        end
    end
end

function listview:__touchup(x,y)
    if self.__drag then
        self.__drag = nil
        if self.__hititem then
            self.__hititem:__ontouchup(x,y)
            self.__hititem = nil
        end
    end
end

function listview:__touchmove(x, y)
    if self.__drag then
        local dragy = y-self.__drag
        if dragy ~= 0 then
            local scale = self:real_wh()/self.__w
            dragy = dragy/scale
            if self.__draw_start==1 and
                self.__dragoff > 0 then
                if dragy > 0 then
                    dragy = dragy*0.4
                end
            elseif self.__draw_start+self.__draw_count-1 > #self.__list then
                if dragy < 0 then
                    dragy = dragy*0.4
                end
            end
            dragy = math.floor(dragy) 
            refresh_drag(self, dragy)
            self.__drag = y
        end
    end
end

function listview:update(dt)
    control.update(self,dt)
    if not self.__drag then
        if self.__draw_start == 1 and
            self.__dragoff > 0 then
            local diff = self.__dragoff
            if diff > 100 then
                diff = 100
            end
            refresh_drag(self, -diff)
        elseif self.__draw_start+self.__draw_count-1 > #self.__list then 
            local _,_,_,y1 = self.__list[#self.__list].__sprite:aabb()
            local _,_,_,y2 = self.__sprite.pannel:aabb()
            local diff = y2-y1
            if diff > 0 then
                if diff > 100 then
                    diff = 100
                end
                refresh_drag(self, diff)
            end
        end
    end
end

function listview:__reset_scale9(w,h)
    local s = self.__sprite.bg
    if s then
        if not self.__scale9 then
            self.__scale9 = scale9.new(s)
        end
        self.__scale9:reset(s, w,h)
    end
end

return listview
