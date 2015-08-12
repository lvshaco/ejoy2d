local logger = require "ejoy2d.logger"

local function toip(gateway)
    return (gateway&0xff) .. '.' ..
    ((gateway>>8)&0xff) .. '.' ..
    ((gateway>>16)&0xff) .. '.' ..
    ((gateway>>24)&0xff)
end

local wifiap = {}

if OS == "ANDROID" then
local javabridge = require "util.javabridge"
function wifiap.create(ssid, passwd, type, timeout)
    --assert(javabridge.call(...))
    javabridge.call("com/example/testej2d/MyActivity", "initWifiApProxy", "V")
    logger.log("wifiap init ok")
    if javabridge.call("com/example/testej2d/WifiApProxy", "isopened", "Z") then
        javabridge.call("com/example/testej2d/WifiApProxy", "close", "V")
    end
    local result = javabridge.call("com/example/testej2d/WifiApProxy", "open", 
        "<", ssid, passwd, type, timeout)
    logger.log("wifiap open result:", result)
    if result == "0" then
        return "0.0.0.0"
    else
        return nil, result
    end
end

function wifiap.join(ssid, passwd, type, timeout) 
    javabridge.call("com/example/testej2d/MyActivity", "initWifiApProxy", "V")
    logger.log("wifiap init ok")
    if javabridge.call("com/example/testej2d/WifiApProxy", "isopened", "Z") then
        javabridge.call("com/example/testej2d/WifiApProxy", "close", "V")
        logger.log("wifiap close")
    else
        logger.log("wifiap not opened")
    end
    -- todo scan后台线程一直在跑
    local result = javabridge.call("com/example/testej2d/WifiApProxy", "scan", "<")
    local found = false
    for w in string.gmatch(result, "[^\n]+") do
        if w == ssid then found = true break end
    end
    logger.log("********:",result, "))))", found)
    if found then
        logger.log("start connect -------")
        local result = javabridge.call("com/example/testej2d/WifiApProxy", "connect",
            "<", ssid, passwd, type, timeout)
        logger.log("connect result:"..result)
        if string.sub(result,1,1) == "0" then
            return toip(tonumber(string.sub(result,2))) 
        else
            return nil, 'NOCONNECT'
        end
    else
        return nil, "NOFOUND"
    end
end

else
function wifiap.create(ssid, passwd, type)
    return "0.0.0.0"
end
function wifiap.join(ssid, passwd, type)
    return "127.0.0.1"
end
end
return wifiap
