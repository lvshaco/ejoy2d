local action = require "util.action"

local actionscale = action.new()
actionscale.__index = actionscale

function actionscale.new(begins, ends, time, formula)
    local self = action.init(actionscale, time, formula)
    self.__begin = begins
    self.__range = ends-begins
    return self
end

function actionscale:__effect(sx) 
    local f = self.__formula(
        self.__begin, 
        self.__range, 
        self.__times, 
        self.__current)        
    sx:scale(f)
end

--function actionscale:prepare(sx)
    ----sx.__sprite:ps(self.__begin)
    --self:__effect(sx)
--end

function actionscale:reverse()
    return actionscale.new(
        self.__begin+self.__range, 
        self.__begin,
        self.__times*1000//30,
        self.__formula)
end

return actionscale
