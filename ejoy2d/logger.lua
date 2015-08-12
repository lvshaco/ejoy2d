local el = require "ejoy2d.log.c"

local logger = {}

function logger.log(...)
    local args = {...}
    local t = {}
    for _, v in ipairs(args) do
        table.insert(t, tostring(v))
    end
    el.log(table.concat(t, ' '))
end

return logger
