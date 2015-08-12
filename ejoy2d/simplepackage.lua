-- It's a simple sprite package warpper, use your own asset format instead.

local ejoy2d = require "ejoy2d"
local fw = require "ejoy2d.framework"
local ppm = require "ejoy2d.ppm"
local pack = require "ejoy2d.spritepack"
local sprite = require "ejoy2d.sprite"
local logger = require "ejoy2d.logger"
local asset
if OS == "ANDROID" then
    asset = require "asset.c"
end

-- This limit defined in texture.c
local MAX_TEXTURE = 128

local textures = {}
local packages = {}

local spack = {}
local package_pattern

local function require_tex(filename)
	local tex = #textures
	assert(tex < MAX_TEXTURE)
	table.insert(textures, filename)
    if OS == "ANDROID" then
        logger.log("open asset:",filename)
        local p1,l1,a1=assert(asset.open(filename..'.ppm'))
        local p2,l2,a2=assert(asset.open(filename..'.pgm'))
        ppm.texture(tex,p1,l1,p2,l2)
        asset.close(a1)
        asset.close(a2)
    else
        ppm.texture(tex,filename)
    end
	return tex
end

function spack.path(pattern)
	package_pattern = pattern
end

local function realname(filename)
	assert(package_pattern, "Need a pattern")
	return string.gsub(package_pattern,"([^?]*)?([^?]*)","%1"..filename.."%2")
end

function spack.preload(packname)
	if packages[packname] then
		return packages[packname]
	end
	local p = {}
	local filename = realname(packname)
	p.meta = assert(pack.pack(dofile(fw.WorkDir..filename .. ".lua")))
	p.tex = {}
	for i=1,p.meta.texture do
		p.tex[i] = require_tex(filename .. "." .. i)
	end
	pack.init(packname, p.tex, p.meta)
	packages[packname] = p
end

function spack.preload_raw(packname)
	if packages[packname] then
		return packages[packname]
	end
	local p = {}
	local filename = realname(packname)
	local data = io.open(filename..".raw", "rb"):read("*a")
	p.meta = assert(pack.import(data))

	p.tex = {}
	for i=1,p.meta.texture do
		p.tex[i] = require_tex(filename .. "." .. i)
	end
	pack.init(packname, p.tex, p.meta)
	packages[packname] = p
end

function ejoy2d.sprite(packname, name)
	if packages[packname] == nil then
		spack.preload(packname)
	end
	return sprite.new(packname, name)
end

function ejoy2d.load_texture(filename)
	return require_tex(filename)
end

function spack.load(tbl)
	spack.path(assert(tbl.pattern))
	for _,v in ipairs(tbl) do
		spack.preload(v)
		collectgarbage "collect"
	end
end

function spack.load_raw(tbl)
	spack.path(assert(tbl.pattern))
	for _,v in ipairs(tbl) do
		spack.preload_raw(v)
	end
	collectgarbage "collect"
end

function spack.texture(packname, index)
	if packages[packname] == nil then
		spack.preload(packname)
	end
	return packages[packname].tex[index or 1]
end

function spack.export(outdir, tbl)
	spack.path(assert(tbl.pattern))
	for _, packname in ipairs(tbl) do
		print("packname    ", packname, outdir, tbl.pattern)
		local filename = string.gsub(outdir..tbl.pattern,
				"([^?]*)?([^?]*)", "%1"..packname.."%2")
		print("spack.export     ",  filename.. ".raw")

		local meta = assert(pack.pack(dofile(filename .. ".lua")))
		local output = pack.export(meta)

		local file = io.open(filename .. ".raw", "w+b")
		file:write(output)
		file:close()
	end
end

return spack
