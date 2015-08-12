local action = {}
action.__index = action

function action.new()
    return setmetatable({}, action)
end

function action.init(class, time, formula)
    local times = time*30//1000
    return setmetatable({
        __formula = formula,
        __times = times,
        __current = 0,
    }, class)
end

function action:__effect(sx)
end

function action:prepare(sx)
    self:__effect(sx)
end

function action:update(sx)
    if self.__current < self.__times then
        self.__current = self.__current+1
        self:__effect(sx)
        return true
    end
end

function action:time()
    return self.__times*1000//30
end

return action
