local table = table
local ipairs = ipairs
local pairs = pairs
local floor = math.floor
--local tbl = require "ex.tbl"

local action = {}

-- action metatable
local mt = {}

function mt.__effect(v, sx)
end

function mt:update(dt, sx)
    if self.__tween:update(dt) then
        self.__effect(self.__tween.__value, sx)
        return true
    end
end

function mt:prepare(sx)
    self.__effect(self.__tween.__value, sx)
end
function mt:reverse()
    self.__tween:reverse()
end
function mt:time()
    return self.__tween.__duration
end

local function __new(tween)
    return setmetatable({__tween = tween}, { __index = mt})
end

-- action group metatable
local mt_group = {}

function mt_group:update(dt, sx)
    local up = false
    for _, a in ipairs(self.__list) do
        if a:update(dt, sx) then
            up = true
        end
    end
    if up then
        return true
    end
end

function mt_group:prepare(sx)
    for _, a in ipairs(self.__list) do
        if a.prepare then
            a:prepare(sx)
        end
    end
end

function mt_group:reverse()
    local g = action.group()
    local l = self.__list
    for _, a in ipairs(l) do
        table.insert(l, a:reverse())
    end
    return g 
end

function mt_group:time()
    local max, t = 0
    for _, a in ipairs(self.__list) do
        t = a:time() 
        if t>max then 
            max = t 
        end 
    end
    return max
end

-- action sequence metatable
local mt_sequence = {}
function mt_sequence:update(dt, sx)
    local i = self.__current
    while i<= #self.__list do
        if self.__list[i]:update(dt, sx) then
            return true
        end
        i = i + 1
        local a = self.__list[i]
        if a then
            if a.prepare then
                a:prepare(sx)
            end
        end
        self.__current = i
    end
end

function mt_sequence:prepare(sx)
    local a = self.__list[1]
    if a then
        if a.prepare then
            a:prepare(sx)
        end
    end
end

function mt_sequence:reverse()
    local seq = action.sequence()
    local l = seq.__list
    for i=#l, 1 do
        a = l[i]
        table.insert(l, a:reverse())
    end
    return seq
end

function mt_sequence:time()
    local sum = 0
    for _, a in ipairs(self.__list) do
        sum = sum + a:time()
    end
    return sum
end

-- action
function action.group(...)
    return setmetatable({
        __list = {...}
    }, { __index=mt_group })
end

function action.sequence(...)
    return setmetatable({
        __list = {...},
        __current = 1
    }, { __index = mt_sequence })
end

function action.wait(duration)
    return __new(tween.new(0,0,duration,nil))
end

function action.position(tw)
    local self = __new(tw)
    self.__effect = function(v, sx)
        sx:position(v.x, v.y)
    end
    return self
end

function action.scale(tw)
    local self = __new(tw)
    self.__effect = function(v, sx)
        sx:scale(v)
    end
    return self
end

function action.scalexy(tw)
    local self = __new(tw)
    self.__effect = function(v, sx)
        sx:scalexy(v.scalex, v.scaley)
    end
    return self
end

local function __color_value(v)
    return (floor(v.a)<<24) | (floor(v.r)<<16) | (floor(v.g)<<8) | floor(v.b)
end

function action.color(tw)
    local self = __new(tw)
    self.__effect = function(v, sx)
        sx.__sprite.color = __color_value(v)
    end
    return self
end

function action.additive(tw)
    local self = __new(tw)
    self.__effect = function(v, sx)
        sx.__sprite.additive = __color_value(v)
    end
    return self
end

return action
