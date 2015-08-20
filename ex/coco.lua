local coco = {}
coco.__index = coco

function coco.new()
    return setmetatable({
        __timer = 0,
        __tick = 0,
        __co = nil,
    }, coco)
end

local function __suspend(self)
    assert(self.__co == nil)
    local co = coroutine.running()
    self.__co = co
    local result = coroutine.yield(co)
    self.__co = nil
    return result
end

local function __wakeup(self, ...)
    assert(coroutine.resume(self.__co, ...))
end

function coco:wait(ms)
    assert(self.__timer == 0)
    self.__timer = ms*30//1000
    self.__tick = 0
    return __suspend(self)
end

function coco:update()
    if self.__timer > 0 then
        self.__tick = self.__tick + 1
        if self.__tick >= self.__timer then
            self.__timer = 0
            __wakeup(self)
        end
    end
end

function coco:click(type, ...)
    local l = {...}
    assert(#l>0)
    if l[#l] == true then
        table.remove(l)
        self.__click = true
    end
    local fl
    if #l > 0 then
        fl = {}
        for i, btn in ipairs(l) do
            local f = btn:touch_event(type, nil)
            local e = btn:touch_enable(true)
            btn:touch_event(type, function(...)
                if f then f(...) end
                --print ("click __wakeup:::", i)
                __wakeup(self, i)
            end)
            fl[i*2-1] = f
            fl[i*2] = e
        end
    end
    local result = __suspend(self)
    --print ("wakeup result:",result)
    if self.__click then
        self.__click = nil
    end
    for i=1,#l do
        local btn = l[i]
        btn:touch_event(type, fl[i*2-1])
        btn:touch_enable(fl[i*2])
    end
    return result
end

function coco:touch(what,x,y)
    if self.__click then
        if what == 'BEGIN' then
            __wakeup(self, 0)
            return true
        end
    end
end

return coco
