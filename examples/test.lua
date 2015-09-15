local png = require "png"

local path = "/Users/lvshaco"
local infile = path.."/ejoy2d/normal_map/diffuse/head.png"
local outfile = path.."/ejoy2d/normal_map/diffuse/head_.png"
local type, width, height, data = png.load(infile)
print (type, width, height, data)
png.save(outfile, type, width, height, data)
print ('save ok')

