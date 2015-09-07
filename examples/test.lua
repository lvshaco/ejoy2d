local png = require "png"

local path = "/Users/lvshaco"
local type, width, height, data = png.load(path.."/ejoy2d/normal_map/diffuse/head.png")

print (type, width, height, data)

png.save(path.."/ejoy2d/normal_map/diffuse/head_.png", type, width, height, data)

