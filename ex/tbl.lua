local tostring = tostring
local type = type
local pairs = pairs
local srep = string.rep
local tinsert = table.insert
local tconcat = table.concat
local sformat = string.format
local sgsub = string.gsub

local tbl = {}

local function _key(k)
    if type(k) == "number" then
        return "["..k.."]"
    else
        return tostring(k)
    end
end

local function _value(v)
    if type(v) == "string" then
        v = sgsub(v, '"', '\\"')
        return sformat('"%s"', v)
    else
        return tostring(v)
    end
end

local function _ns_key(ns, k)
    if type(k) == "number" then
        return ns.."["..k.."]"
    else
        return ns.."."..tostring(k)
    end
end

function tbl.serialize(t, name)
    local cache = { [t] = name }
	local function serialize(t, name, tab, ns)
        local tab2 = tab.."  "
        local fields = {}
		for k, v in pairs(t) do
			if cache[v] then
                tinsert(fields, tostring(k).."="..cache[v])
			else
                if type(v) == "table" then
                    local ns_key = _ns_key(ns, k)
				    cache[v] = ns_key
				    tinsert(fields, serialize(v, k, tab2, ns_key))
                else
                    tinsert(fields, _key(k).."=".._value(v))
                end
			end
		end	
        return _key(name).."={\n"..tab2..
            tconcat(fields, ",\n"..tab2).."\n"..tab.."}"
	end	
	return serialize(t, name, "", name)
end

function tbl.print(t, name, out)
    out = out or print
    out(tbl.serialize(t, tostring(name)))
end

return tbl
