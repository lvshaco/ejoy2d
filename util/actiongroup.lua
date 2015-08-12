local actiongroup = {}
actiongroup.__index = actiongroup

function actiongroup.new(...)
    return setmetatable({
        __list = {...},
    }, actiongroup)
end

function actiongroup.init(class, ...)
    return setmetatable({
        __list = {...},
    }, class)
end

function actiongroup:update(sx)
    local up = false
    for _, act in ipairs(self.__list) do
        if act:update(sx) then
            up = true
        end
    end
    if up then
        return true
    end
end

function actiongroup:prepare(sx)
    for _, act in ipairs(self.__list) do
        if act.prepare then
            act:prepare(sx)
        end
    end
end

function actiongroup:reverse()
    local a = actiongroup.new()
    for _, act in ipairs(self.__list) do
        table.insert(a.__list, act:reverse())
    end
    return a
end

function actiongroup:time()
    local max = 0
    for _, a in ipairs(self.__list) do
        local t = a:time()
        if t>max then
            max = t
        end
    end
    return max
end

return actiongroup
