local action = require "util.action"

local actionadditive = action.new()
actionadditive.__index = actionadditive

function actionadditive.new(color1, color2, time, formula)
    local self = action.init(actionadditive, time, formula)
    local r1,g1,b1 = (color1>>16)&0xff, (color1>>8)&0xff, color1&0xff
    local r2,g2,b2 = (color2>>16)&0xff, (color2>>8)&0xff, color2&0xff
    self.__r1 = r1
    self.__rr = r2-r1
    self.__g1 = g1
    self.__gr = g2-g1
    self.__b1 = b1
    self.__br = b2-b1
    return self
end

function actionadditive:__effect(sx) 
    local r = self.__formula(self.__r1, self.__rr, self.__times, self.__current)
    local g = self.__formula(self.__g1, self.__gr, self.__times, self.__current)
    local b = self.__formula(self.__b1, self.__br, self.__times, self.__current)
    sx.__sprite.additive = (0xff<<24) | 
        (math.floor(r)<<16) | 
        (math.floor(g)<<8) | 
        (math.floor(b))
end

function actionadditive:reverse()
    local r,g,b = self.__r1+self.__rr,
        self.__g1+self.__gr, self.__b1+self.__br
    return actionadditive.new(
        (self.__r1<<16) | (self.__g1<<8) | (self.__b1),
        (r<<16) | (g<<8) | b,
        self.__times*1000//30,
        self.__formula)
end

return actionadditive
