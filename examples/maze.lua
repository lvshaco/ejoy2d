local math = math

local seed = os.time()
--local seed = 1436871812
print ("[RANDOM SEED]"..seed)
math.randomseed(seed)

local W, H, map

local NEAR = {false, false, false, false}
local DIR = {false, false, false, false}
local OPT = {2,3,0,1}
--[[
L: 1
T: 2
R: 4
B: 8
--]]

local function dump()
    local tmp = {'+'..string.rep('--+',W)}
    local s
    for y=0, H-1 do
        s = '|'
        for x=1, W do
            local i = y*W+x
            s = s..'  '
            if map[i].tag&4 ~= 0 then
                s = s..'|'
            else
                s = s..' '
            end
        end
        table.insert(tmp, s)
        s = '+'
        for x=1, W do
            local i = y*W+x
            if map[i].tag&8 ~= 0 then
                s = s..'--'
            else
                s = s..'  '
            end
            if (map[i].tag&4 ~= 0) or
               (map[i].tag&8 ~= 0) or
               (x<W and map[i+1].tag&8 ~= 0) or
               (y<H-1 and map[i+W].tag&4 ~= 0) then
                s = s..'+'
            else
                s = s..' '
            end
        end
        table.insert(tmp, s)
    end
    print (table.concat(tmp, '\n'))
end

--[[
+--++--+
|  ||  |
+--++--+
****
****
****
]] 
local function dump_wall()
    local tmp = {}
    for y=1,H do
        local s1,s2,s3 = '','',''
        for x=1,W do
            local t = map[(y-1)*W+x]
            
            if t.tag == 0 then
                s1 = s1..'*****'
                s2 = s2..'*****'
                s3 = s3..'*****'
            else
                s1 = s1..'+---+'
                s2 = s2..'|   |'
                s3 = s3..'+---+'
            end
        end
        table.insert(tmp, s1)
        table.insert(tmp, s2)
        table.insert(tmp, s3)
    end
    print(table.concat(tmp, '\n'))
end

--http://weblog.jamisbuck.org/2010/12/29/maze-generation-eller-s-algorithm#
function Eller(w, h)
    W,H = w,h
    map = {}
    for i=1, w*h do
        map[i] = {tag=15, num=i}
    end
   
    local tmp
    for y=0, h-2 do
        for x=1, w-1 do
            local i=y*w + x
            if map[i].num ~= map[i+1].num then
                if math.random(1) == 1 then
                    map[i].tag = map[i].tag-4
                    map[i+1].tag = map[i+1].tag-1
                    map[i+1].num = map[i].num
                end
            end
        end
        tmp = {}
        for x=1, w do
            local i = y*w + x
            if math.random(1) == 1 then
                map[i].tag = map[i].tag-8
                map[i+w].tag = map[i+w].tag-2
                map[i+w].num = map[i].num
                tmp[map[i].num] = true
            end
        end
        for x=1, w do
            local i = y*w + x
            local n = map[i].num
            if not tmp[n] then
                map[i].tag = map[i].tag-8
                map[i+w].tag = map[i+w].tag-2
                map[i+w].num = map[i].num
                tmp[n] = true
            end
        end
    end

    for x=1, w-1 do
        local i =(h-1)*w + x
        if map[i].num ~= map[i+1].num then
            map[i].tag = map[i].tag-4
            map[i+1].tag = map[i+1].tag-1
            map[i+1].num = map[i].num
        end
    end
    dump()
end

--http://weblog.jamisbuck.org/2010/12/27/maze-generation-recursive-backtracking
local function near(i)
    local h = (i-1)//W
    local w = (i-1)%W
    local idx
    local n = 0
    if h>0 and not map[i-W].visited then
        n = n+1
        NEAR[n] = i-W -- 2
        DIR[n] = 1
    end
    if w<W-1 and not map[i+1].visited then
        n=n+1
        NEAR[n] = i+1 -- 3
        DIR[n] = 2
    end
    if h<H-1 and not map[i+W].visited then
        n= n+1
        NEAR[n] = i+W -- 4
        DIR[n] = 3
    end
    if w>0 and not map[i-1].visited then
        n=n +1
        NEAR[n] = i-1
        DIR[n] = 0
    end
    if n > 0 then
        local i = math.random(n)
        return NEAR[i], DIR[i]
    end
end

function r_bt(w,h)
    W, H = w,h
    map = {}
    for i=1, w*h do
        map[i] = {tag=15, visited=false}
    end

    local start = math.random(w*h)
    local st = {}
   
    table.insert(st, start)
    map[start].visited = true

    while #st>0 do
        local index = #st
        local i = st[index]
        local ni, dir = near(i)
        if ni then
            table.insert(st, ni)
            --print (i, ni, dir, map[ni].visited, map[ni].tag)
            assert(not map[ni].visited)
            map[ni].visited = true
            map[ni].tag = map[ni].tag & (~(2^(OPT[dir+1]&0xf)))
            map[i].tag = map[i].tag & (~((2^dir)&0xf))
        else
            local pop = table.remove(st, index) 
            --print (pop, map[pop].tag, map[pop].visited)
            if pop == start then
                --found = true
            else
                -- one is ok
            end
        end
    end

    dump()
end

--http://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm
function gtree()
    -- 灵活可配置, r_bt(newest), prim(random)
    w,h = W,H
    map = {}
    for i=1, w*h do
        map[i] = {tag=15, visited=false}
    end

    local start = math.random(w*h)
    local st = {}
   
    table.insert(st, start)
    map[start].visited = true

    while #st>0 do
        --local index = #st -- newest [ recursive backtracking]
        local index = math.random(#st) -- random [prim]
        --local index = 1 -- oldest, or middle, or mix, etc
        
        local i = st[index]
        local ni, dir = near(i)
        if ni then
            table.insert(st, ni)
            --print (i, ni, dir, map[ni].visited, map[ni].tag)
            assert(not map[ni].visited)
            map[ni].visited = true
            map[ni].tag = map[ni].tag & (~(2^(OPT[dir+1]&0xf)))
            map[i].tag = map[i].tag & (~((2^dir)&0xf))
        else
            local pop = table.remove(st, index)
            --print (pop, map[pop].tag, map[pop].visited)
            if pop == start then
                --found = true
            else
                -- one is ok
            end
        end
    end
    
    dump()
end

--http://weblog.jamisbuck.org/2011/1/12/maze-generation-recursive-division-algorithm.html
local D = 2
function r_division()
    W,H = W+2, H+2
    w,h = W,H
    map = {}
    for y=1,H do
        for x=1,W do
            local i = (y-1)*W+x
            if y==1 or y==H or x==1 or x==W then
                map[i] = {tag=1}
            else
                map[i] = {tag=0}
            end
        end
    end
   --print (w,h,W,H) 
    local x1,x2, y1,y2
    local st = {}
    table.insert(st, {2, w-1, 2, h-1})
    while #st > 0 do
        local div = table.remove(st, #st)
        x1,x2, y1,y2 = div[1],div[2], div[3],div[4]
        --print (x1,x2, y1,y2)
        if x2-x1 >= y2-y1 then
            --print ("V")
            -- add V wall
            local x=math.random(x1+1, x2-1)
            local times = 1
            while map[(y1-2)*W+x].tag==0 or map[y2*W+x].tag==0 do
                if times>x2-1-x1-1 then
                    x=nil
                    break
                end
                x=math.random(x1+1, x2-1)
                times = times+1
            end
            if x then
                local hole = math.random(y1,y2)
                for i=y1,y2 do
                    if i ~= hole then
                        map[(i-1)*W+x].tag = 1
                    end
                end
                if x-x1>D or y2-y1+1>D then
                    table.insert(st, {x1,x-1, y1,y2})
                end
                if x2-x>D or y2-y1+1>D then
                    table.insert(st, {x+1,x2, y1,y2})
                end
            end
        else
            --print ("H")
            -- add H wall
            local y=math.random(y1+1, y2-1)
            local times = 1
            while map[(y-1)*W+x1-1].tag==0 or map[(y-1)*W+x2+1].tag==0 do
                if times>y2-1-y1-1 then
                    y=nil
                    break
                end
                y=math.random(y1+1, y2-1)
                times = times+1
            end
            if y then
                local hole = math.random(x1,x2)
                for i=x1,x2 do
                    if i ~= hole then
                        map[(y-1)*W+i].tag = 1
                    end
                end
                if x2-x1+1>D or y-y1>D then
                    table.insert(st, {x1,x2, y1,y-1})
                end
                if x2-x1+1>D or y2-y>D then
                    table.insert(st, {x1,x2, y+1,y2})
                end
            end
        end
        --dump_wall()
    end
    dump_wall()
end

--http://weblog.jamisbuck.org/2015/1/15/better-recursive-division-algorithm.html
function division(w,h)
end

--http://weblog.jamisbuck.org/2011/1/24/maze-generation-hunt-and-kill-algorithm.html
function hunt_and_kill(w, h)
end

--http://weblog.jamisbuck.org/2011/2/1/maze-generation-binary-tree-algorithm.html
function btree(w, h)
end

--http://weblog.jamisbuck.org/2011/2/3/maze-generation-sidewinder-algorithm.html
function sidewinder(w,h)
end

W,H = 15,15
print "Eller"
Eller(W,H)
print "backtracking"
r_bt(W,H)
print "glow tree"
gtree()
print "division"
r_division()
--+--+--+--+
--|  |  |  |
--+--+--+--+
--|  |  |  |
--+--+--+--+
