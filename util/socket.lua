local c = require "socket.c"
local socketbuffer_c = require "socketbuffer.c"
local coroutine = coroutine

local socketbuffer = function()
    local self = socketbuffer_c.new()
    return debug.setmetatable(self, {__index = socketbuffer_c})
end

local socket_pool = {}

local function wakeup(co, ...)
    assert(coroutine.resume(co, ...))
end

local function suspend(s)
    assert(s.co == coroutine.running())
    return coroutine.yield() 
end

local function disconnect(id, force)
    local s = socket_pool[id]
    assert(s)
    assert(s.id == id)
    c.close(id, force)
    socket_pool[id] = nil
end

local LS_EREAD    =0
local LS_EACCEPT  =1 
local LS_ECONNECT =2 
local LS_ECONNERR =3 
local LS_ESOCKERR =4

local event = {}

event[LS_EREAD] = function(id)
    local s = socket_pool[id] 
    if s == nil then return end
    local data, n = c.read(id)
    if data then
        s.buffer:push(data, n)
        local data = s.buffer:pop(s.mode)
        if data then
            wakeup(s.co, data)
        end
    elseif n then
        local co = s.co
        disconnect(id, true)
        wakeup(co, nil, c.error(n))
    end
end

event[LS_EACCEPT] = function(id, listenid) 
    local listen_s = socket_pool[listenid] 
    listen_s.callback(id)
end

event[LS_ECONNECT] = function(id)
    local s = socket_pool[id]
    assert(s.id == id)
    wakeup(s.co, s.id)
end

event[LS_ECONNERR] = function(id, err)
    local s = socket_pool[id]
    assert(s.id == id)
    disconnect(id, true)
    wakeup(s.co, nil, c.error(err))
end

event[LS_ESOCKERR] = function(id, err)
    local s = socket_pool[id]
    assert(s.id == id)
    disconnect(c, true)
    wakeup(s.co, nil, c.error(err)) 
end

local socket = {}

function socket.listen(ip, port)
    return c.listen(ip, port)
end

function socket.connect(ip, port)
    local id, err, conning = c.connect(ip, port)
    if id then
        socket.start(id)
        if conning then
            local s = socket_pool[id]
            return suspend(s)
        else return id end
    else return nil, c.error(err)
    end
end

function socket.start(id, callback)
    assert(socket_pool[id] == nil)
    socket_pool[id] = { 
        id = id,
        co = coroutine.running(),
        buffer = nil,
        mode = "*l",
        callback = callback,
    }
end

function socket.bind(id, co)
    local s = socket_pool[id]
    assert(s)
    s.co = co
end

function socket.shutdown(id)
    disconnect(id, false)
end

function socket.close(id)
    disconnect(id, true)
end

function socket.readenable(id, enable)
    local s = socket_pool[id]
    assert(s) 
    c.readenable(id, enable)
    if enable and not s.buffer then     
        s.buffer = socketbuffer()
    end
end

function socket.read(id, mode)
    local s = socket_pool[id]
    assert(s)
    assert(s.id == id)
    s.mode = mode
    local data = s.buffer:pop(mode)
    if data then
        return data
    else
        return suspend(s)
    end
end

function socket.send(id, data, i, j)
    local err = c.send(id, data, i, j)
    if err then
        disconnect(id, true)
        return nil, c.error(err)
    else return true end
end

function socket.init(cmax)
    return c.init(cmax, function(type,...)
        local f = event[type]
        if f then f(...) end
    end)
end

socket.fini = c.fini
socket.poll = c.poll

return socket
