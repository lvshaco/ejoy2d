local action = require "util.action"

local actionpos = action.new()
actionpos.__index = actionpos

function actionpos.new(beginx, beginy, endx, endy, time, formula)
    local self = action.init(actionpos, time, formula)
    self.__beginx = beginx
    self.__rangex = endx-beginx
    self.__beginy = beginy
    self.__rangey = endy-beginy
    return self
end

function actionpos:__effect(sx)
    local x = self.__formula(
        self.__beginx,
        self.__rangex,
        self.__times,
        self.__current)
    local y = self.__formula(
        self.__beginy,
        self.__rangey,
        self.__times,
        self.__current)
    -- todo 坐标抖动问题
    --local x1,y1,x2,y2 = sx.__sprite:aabb()
    --x = x - (x2-x1)//2
    --y = y - (y2-y1)//2
    --sx.__sprite:ps(x,y)
    sx:ps(x,y)
end

function actionpos:reverse()
    return actionpos.new(
        self.__beginx + self.__rangex,
        self.__beginy + self.__rangey,
        self.__beginx,
        self.__beginy,
        self.__times*1000//30,
        self.__formula)
end

return actionpos
