local math = math

local util = {}

function util.fork(f,...)
    local m = function(...)
        assert(xpcall(f,debug.traceback,...))
    end
    local co = coroutine.create(m)
    assert(coroutine.resume(co,...))
    --assert(coroutine.resume(coroutine.create(f),...))
end

function util.random(rand_seed)
    return function(n)
        rand_seed=rand_seed*1103515245 + 12345
        return rand_seed//65536%n + 1
    end
end

function util.wh(o)
    local x1,y1,x2,y2 = o:aabb(screecoord)
    return x2-x1, y2-y1
end

function util.index2ps(x,y)
    local off = C.OFF
    local px = (x-1)*C.CW + C.BX + off
    local py
    if C.IS_BLACK then py = (9-(y-1))*C.CH + C.BY + off
    else             py = (y-1)*C.CH + C.BY + off
    end
    return px,py
end

function util.ps2index(x,y)
    local off = C.OFF
    local ix = math.floor((x-C.BX-off)/C.CW)+1
    local iy = math.floor((y-C.BY-off)/C.CH)+1
    if C.IS_BLACK then iy = 10-iy+1
    end
    return ix,iy 
end

function util.scale(o, f)
    local x1,y1,x2,y2 = o:aabb(screencoord)
    local w,h = x2-x1+1, y2-y1+1
    local w2,h2 = math.floor(w*f), math.floor(h*f)
    local x1 = x1-(w2-w)/2
    local y1 = y1-(h2-h)/2
    o:ps(x1,y1,f*C.SCALE) 
end

function util.t_add(list, ...) 
    local l = {...}
    for _, sx in ipairs(l) do
        --sx.__sprite.program = 'EDGE'
        table.insert(list, sx)
    end
end

function util.t_remove(list, ...)
    local l = {...}
    for _, del in ipairs(l) do
        for i, s in ipairs(list) do
            if s == del then
                table.remove(list, i)
                break
            end
        end
    end
end

function util.t_top(list, sx)
    for i, s in ipairs(list) do
        if s == sx then
            table.remove(list, i) 
            break
        end
    end
    table.insert(list, sx)
end


return util
