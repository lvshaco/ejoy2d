local actiongroup = require "util.actiongroup"

local actionsequence = actiongroup.new()
actionsequence.__index = actionsequence

function actionsequence.new(...)
    local self = actiongroup.init(actionsequence, ...)
    self.__current = 1
    return self
end

function actionsequence:update(sx)
    local i = self.__current
    while i<= #self.__list do
        if not self.__list[i]:update(sx) then
            i = i + 1
            local act = self.__list[i]
            if act then
                if act.prepare then
                    act:prepare(sx)
                end
            end
            self.__current = i
        else
            return true
        end
    end
end

function actiongroup:prepare(sx)
    local act = self.__list[1]
    if act then
        if act.prepare then
            act:prepare(sx)
        end
    end
end

function actionsequence:reverse()
    local a = actionsequence.new()
    for _, act in ipairs(self.__list) do
        table.insert(a.__list, 1, act:reverse())
    end
    return a
end

function actionsequence:time()
    local sum = 0
    for _, a in ipairs(self.__list) do
        sum = sum + a:time()
    end
    return sum
end

return actionsequence
