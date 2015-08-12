local c = require "audio.c"

local audio = {}
audio.init = assert(c.init)

local __pool = {}

local method = c.method
local get = c.get
local set = c.set

local audiodata_meta = {
    __index = function(a, key)
        local m = method[key]
        if m then
            return m
        end
        local getter = get[key]
        if getter then
            return getter(a)
        end
        print("Unsupport audiodata get "..key)
        return nil
    end,
    __newindex = function(a, key, value)
        local setter = set[key]
        if setter then
            setter(a, value)
            return
        end
        print("Unsupport audiodata set "..key)
    end,
}

function audio.load(name)
    local a = assert(c.load(name))
    debug.setmetatable(a, audiodata_meta)
    __pool[name] = a
    return a
end

function audio.unload(name)
    local a = __pool[name]
    a:unload()
end

function audio.play(name, volume)
    local a = __pool[name]
    a:play(volume or 1.0)
end

function audio.stop(name)
    local a = __pool[name]
    a:stop()
end

function audio.pause(name)
    local a = __pool[name]
    a:pause()
end

function audio.resume(name)
    local a = __pool[name]
    a:resume()
end

function audio.rewind(name)
    local a = __pool[name]
    a:rewind()
end

return audio
