local action = require "util.action"

local actionwait = action.new()
actionwait.__index = actionwait

function actionwait.new(time)
    return action.init(actionwait,time)
end

return actionwait
