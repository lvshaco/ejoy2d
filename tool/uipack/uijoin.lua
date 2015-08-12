local args = {...}
local file_export = table.remove(args)

local tl = {}
for _, f in ipairs(args) do
    print('[+]'..f)
    local t = dofile(f)
    table.insert(tl,t)
end

local T = tl[1]

local function find_byid(t, id)
    for _, v in ipairs(t) do
        if v.id == id then
            return v
        end
    end
    error(string.format('Can not found id:%d',id))
end

local function find_byname(t, name)
    for _, v in ipairs(t) do
        if v.export == name then
            return v
        end
    end
    error(string.format('Can not found name:%s',name))
end

-- make sure __newid filed no exist, we will use it temp
for i=2,#tl do
    local t = tl[i]
    for _,v in ipairs(t) do
        if v.type == 'animation' then
            for _, c in ipairs(v.component) do
                assert(c.__newid==nil,  
                string.format('__newid filed is no expired in component:%s.[%d]%s',
                args[i],v.id,v.export))
            end
        end
    end
end

-- cache internal picture newid 
for i=2,#tl do
    local t = tl[i]
    for _,v in ipairs(t) do
        if v.type == 'animation' then
            for _, c in ipairs(v.component) do
                if c.id then
                    local one = find_byid(t, c.id)
                    if one.type == 'picture' then
                        local one = find_byname(T, one.export)
                        c.__newid = one.id
                    end
                end
            end
        end
    end
end

-- remove picture
for i=2,#tl do
    local t = tl[i]
    local i = 1
    while i<#t do
        local v = t[i]
        if v.type == 'picture' then
            table.remove(t,i)
        else i=i+1 end
    end
end

-- find start id
local startid = -1
for _, v in ipairs(T) do
    if v.id > startid then
        startid = v.id
    end
end

-- cache newid
for i=2,#tl do
    local t = tl[i]
    for _,v in ipairs(t) do
        startid = startid+1
        v.__newid = startid
    end
end

-- fix internal id (component)
for i=2,#tl do
    local t = tl[i]
    for _,v in ipairs(t) do
        if v.type == 'animation' then
            for _, c in ipairs(v.component) do
                if c.id then
                    if not c.__newid then
                        local one = find_byid(t, c.id)
                        c.id = one.__newid
                    else
                        c.id = c.__newid
                        c.__newid = nil
                    end
                end
            end
        end
    end
end

-- fix id
for i=2,#tl do
    local t = tl[i]
    for _,v in ipairs(t) do
        v.id = v.__newid
        v.__newid = nil
    end
end

-- combine
for i=2,#tl do
    local t = tl[i]
    table.move(t,1,#t,#T+1,T)
end

-- export
local HEAD = [[
    type = %q,
    id = %d,%s
]]
local PICTURE = [[
    {tex=%d, src={%s}, screen={%s}}
]]
local LABEL = [[
    color=0x%08x, align=%d, size=%d, width=%s, height=%s, 
    noedge=%s, space_w=%d, space_h=%d, auto_size=%d
]]
local PANNEL = [[
    width=%s, height=%s, scissor=%s
]]
local ANIMATION = [[
    component={
        %s
    },
    %s
]]
local function export_head(v)
    return string.format(HEAD, v.type, v.id, 
    v.export and string.format('\n    export = %q,',v.export) or '')
end

local function export_picture(v)
    local t = {}
    for _,tex in ipairs(v) do
        local s = 
        string.format(PICTURE, tex.tex,
            table.concat(tex.src,','),
            table.concat(tex.screen,','))
        table.insert(t,s)
    end
    return table.concat(t, ',\n    ')
end

local function export_label(v)
    return string.format(LABEL, v.color, v.align, v.size, v.width,
        v.height, v.noedge and "true" or "false", 
        v.space_w or 0, v.space_h or 0, auto_size or 0)
end

local function export_pannel(v)
    return string.format(PANNEL, v.width, v.height, v.scissor and 'true' or 'false')
end

local function export_animation(v)
    local t_c = {}
    local s
    for _, c in ipairs(v.component) do
        local t_i = {}
        if c.id then
            table.insert(t_i, 'id='..c.id)
        end
        if c.name then
            table.insert(t_i, string.format('name=%q', c.name)) 
        end
        table.insert(t_c, '{'..table.concat(t_i,',')..'}')
    end
    local s_c = table.concat(t_c, ',\n        ')
    local t_a = {}
    for _, a in ipairs(v) do
        local t_f = {}
        if a.action then
            table.insert(t_f, string.format('action=%q',a.action))
        end
        for _, f in ipairs(a) do
            local t_p = {}
            for _, part in ipairs(f) do
                local ty = type(part)
                if ty == 'table' then
                    table.insert(t_p, string.format('{index=%d%s%s}', 
                    part.index,
                    part.mat and ', mat={'..table.concat(part.mat, ',')..'}' or '',
                    part.touch and ', touch=true' or ''))
                elseif ty == 'number' then
                    table.insert(t_p, tostring(part))
                end
            end
            table.insert(t_f, '{'..table.concat(t_p, ',')..'}')
        end
        table.insert(t_a, '{\n        '..table.concat(t_f, ',\n        ')..'\n    }')
    end
    local s_a = table.concat(t_a, ',\n    ')
    return string.format(ANIMATION, s_c, s_a)
end

local EP = {
    picture = export_picture,
    label = export_label,
    pannel = export_pannel,
    animation = export_animation,
}

local t_export = {}
for _, v in ipairs(T) do
    local ep = assert(EP[v.type], 'Can no export type:'..v.type)
    local head = export_head(v)
    local body = ep(v)
    table.insert(t_export, '{\n'..head..body..'}')
end

print('[=]'..file_export)
local f = io.open(file_export, 'w')
f:write('return {\n')
f:write(table.concat(t_export, ',\n'))
f:write('}')
f:close()
