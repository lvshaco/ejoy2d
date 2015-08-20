local ipairs = ipairs
local pairs = pairs

local UPDATE = 1
local DRAW = 2
local TOUCH = 4
local RESIZE = 8
local TOUCHLAST = 16 -- coco 使用这个touch，使其最后触发，
                     -- coco touch screen总是会触发的，必须留到最后

local layer = {
    UPDATE = UPDATE,
    DRAW   = DRAW,
    TOUCH  = TOUCH,
    TOUCHLAST  = TOUCHLAST,
    RESIZE = RESIZE,
    ALL = UPDATE|DRAW|TOUCH|RESIZE,
}
layer.__index = layer

function layer.new()
    return setmetatable({
        __max = 0,
        __all = {},
    }, layer)
end

local function __reset_max(self, depth)
    if depth > self.__max then
        self.__max = depth
    end
end

function layer:bind(depth,l,itf,flag)
    assert(l)
    assert(self.__all[depth]==nil)
    assert((itf==pairs) or (itf==ipairs))
    self.__all[depth] = {iter=itf, flag=flag, items=l}
    __reset_max(self,depth)
end

function layer:add(depth,...)
    local l = self.__all[depth]
    assert(l)
    local t = {...}
    local items = l.items
    table.move(t,1,#t,#items+1,items)
end

function layer:del(depth,...)
    local l = self.__all[depth]
    if not l then
        return
    end
    local t = {...}
    local items = l.items
    for _, del in ipairs(t) do
        for i, v in ipairs(items) do
            if v == del then
                table.remove(items, i)
                break
            end
        end
    end
end

function layer:top(depth, v)
    local l = self.__all[depth]
    assert(l)
    local items = l.items
    for i, one in ipairs(items) do
        if one == v then
            table.remove(items,i)
            break
        end
    end
    table.insert(items,v)
end

function layer:clr(depth)
    local l = self.__all[depth]
    assert(l)
    l.items = {}
end

function layer:update()
    local l
    for i=1,self.__max do
        l = self.__all[i]
        if l then
            if l.flag&UPDATE ~=0 then
                for _, v in l.iter(l.items) do
                    v:update()
                end
            end
        end
    end
end

function layer:draw()
    local l
    for i=1,self.__max do
        l = self.__all[i]
        if l then
            if l.flag&DRAW~=0 then
                for _, v in l.iter(l.items) do
                    v:draw()
                end
            end
        end
    end
end

local function __touch(self,what,x,y,flag)
    local l
    for i=self.__max,1,-1 do
        l = self.__all[i]
        if l then
            if l.flag&flag ~=0 then -- reverse iter if ipairs
                for _, v in l.iter(l.items) do
                    if v:touch(what,x,y) then
                        return true
                    end
                end
            end
        end
    end
end

function layer:touch(what,x,y)
    if __touch(self,what,x,y,TOUCH) then
        return true
    end
    if __touch(self,what,x,y,TOUCHLAST) then
        return true
    end
end

function layer:resize(w,h)
    local l
    for i=1,self.__max do
        l = self.__all[i]
        if l then
            if l.flag&RESIZE ~=0 then
                for _, v in l.iter(l.items) do
                    v:resize(w,h)
                end
            end
        end
    end
end

return layer
