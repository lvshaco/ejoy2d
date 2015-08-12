local c = require "javabridge.c"
local logger = require "ejoy2d.logger"

local javabridge = {}

local POOL = {}

local function dispatch(id, result)
    local co = POOL[id]
    logger.log(co)
    POOL[id] = nil
    assert(coroutine.resume(co, result))
end

function javabridge.call(class, method, ret, ...)
    if ret == "<" then
        local co, ismain = coroutine.running()
        assert(not ismain)
        logger.log("javabridge.call begin "..class.."."..method)
        local id = c.callstaticmethod(class,method,dispatch,...)
        logger.log("javabridge.call end")
        assert(POOL[id] == nil)
        POOL[id] = co
        return coroutine.yield()
    else
        return c.callstaticmethod(class,method,ret,...)
    end
end

return javabridge
