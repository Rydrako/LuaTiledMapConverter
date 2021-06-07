-- Copyright (c) 2021 Rydrako. All rights reserved.
--
-- This file is a part of Lua Tiled Map Converter
-- This work is licensed under the terms of the GPL-3.0 license
-- For a copy, see <https://opensource.org/licenses/GPL-3.0>.

-- Conversion Module
local conversionTool = {}
local conversionUtil = require("conversionUtil")
local polygonUtil = require("polygonUtil")
local debugUtil = require("debugUtil")
local util = require("util")
local ioUtil = require("ioUtil")

tiles_to_pixels = function (input, use_width)
	return input * tonumber(use_width and data["tilewidth"] or data["tileheight"])
end

pixels_to_tiles = function (input, use_width)
	return input / tonumber(use_width and data["tilewidth"] or data["tileheight"])
end

--- Creates a json file for Tiled from the given lua file, returns true/false if the operation was successful or not
--
-- @param 	string 	file 			path of the input lua file
-- @param 	string 	exportPath		path to create the json file
-- @param	string 	imgpath			path where tilesets are located; if empty, exportPath is used
-- @param 	number 	margin 			margin of tilesets
-- @param 	number 	spacing 		spacing of tilesets

function conversionTool.toTiled (file, exportPath, imgPath, margin, spacing)

	data = ioUtil.load_file(file)

	if util.is_nil_or_empty(data) then 

		print(" loading lua data failed ")
		return false
	end

	print("converting " .. file .. "to json...")

	if util.is_nil_or_empty(imgPath) then
		imgPath = util.is_dir(exportPath) and exportPath or util.get_parent_path(exportPath)
	end

	data["orientation"] = "orthogonal"
	conversionUtil.start_iteration_process(data, function (set)

			conversionUtil.remove_keys(set, {"encoding", ""}, 
				{
					"tilelayer",
					"objectgroup",
					"group"
				})

			conversionUtil.add_entries_for_each_layer(set, 
				{
					x = 0,
					y = 0,
					opacity = 1,
					visible = true
				}, 
				{
					"group", 
					"tilelayer", 
					"objectgroup"
				})

			conversionUtil.convert_custom_properties_to_tiled(set)

			conversionUtil.convert_each_entry(set, 
				{
					"tileX",
					"tileY", 
					"widthInTiles", 
					"heightInTiles"
				}, 
				{
					"x",
					 "y", 
					"width", 
					"height"
				}, 
				tiles_to_pixels)

			polygonUtil.convert_tile_data_to_polygons(set, "tiles", 
				{
					"grassArea",
					""
				})

			conversionUtil.locate_tileset_images(set, imgPath, 
				util.is_nil_or_empty(margin) and 0 or margin, 
				util.is_nil_or_empty(spacing) and 0 or spacing)
		
		end)


	if not ioUtil.export_file(exportPath, data, util.get_filename(file), ".json") then 

		print(" json export failed ")
		return false 
	end

	if not ioUtil.export_file(exportPath, data["tilesets"], util.get_filename(file) .. "_tilesets", ".json") then 

		print(" tileset export failed ")
		return false 
	end

	print("Conversion done!")
	return true
end

--- Creates a lua file for Tiled from the given json file, returns true/false if the operation was successful or not
--
-- @param 	string 	file 			path of the input json file
-- @param 	string 	exportPath		path to create the lua file
-- @param	string 	imgpath			path of tilesets

function conversionTool.toLua (file, exportPath, imgPath)

	data = ioUtil.load_file(file)

	local tilesetFile = util.get_parent_path(file) .. "\\" .. util.get_filename(file) .. "_tilesets.json"
	data["tilesets"] = ioUtil.load_file(tilesetFile)

	if util.is_nil_or_empty(data) then 

		print("loading json data failed")
		return false
	end

	print("converting " .. file .. " to lua...")

	--add "\" to imgPath if it does not end with one
	if imgPath:sub(-string.len("\\")) ~= "\\" then 
		imgPath = imgPath .. "\\"
	end

	data["orientation"] = nil

	if data["properties"] == nil then 
		data["properties"] = {}
	end

	conversionUtil.start_iteration_process(data, function (set)

			conversionUtil.remove_keys(set, 
				{
					"x",
					"y"
				},
				{
					"tilelayer",
					"objectgroup",
					"group"
				})

			conversionUtil.remove_keys(set, 
				{
					"opacity",
					"visible",
					"rotation"
				},
				{
					match="all"
				})		

			conversionUtil.convert_custom_properties_to_lua(set)
			
			polygonUtil.convert_polygons_to_tiles(set, "polygon", 
				{
					"grassArea",
					""
				})

			conversionUtil.iterate_sets_with_key(set, "objects", function (set)

					conversionUtil.convert_each_entry(set, 
							{
								"x",
								"y", 
								"width", 
								"height"
							},
							{
								"tileX",
								"tileY", 
								"widthInTiles", 
								"heightInTiles"
							},
							pixels_to_tiles)
				end)

			conversionUtil.add_object_tiles(set, "objects")
			conversionUtil.convert_tileset_paths(set, imgPath)
			conversionUtil.remove_empty_keys(set)

		end)

	if not ioUtil.export_file(exportPath, data, util.get_filename(file), ".lua") then 

		print(" lua export failed")
		return false
	end

	print("Conversion done!")
	return true
end

return conversionTool