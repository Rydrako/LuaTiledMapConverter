-- Copyright (c) 2021 Rydrako. All rights reserved.
--
-- This file is a part of Lua Tiled Map Converter
-- This work is licensed under the terms of the GPL-3.0 license
-- For a copy, see <https://opensource.org/licenses/GPL-3.0>.

-- Conversion Utility Module
local conversionUtil = {}
local util = require("util")

--- Starts an iteration through the entire table given and executes the given method on each data set
-- 
-- @param 	table 		map_data 	table of map data to iterate on
-- @param 	function 	process 	function to execute with each set of data, reqiures the params: (table)

function conversionUtil.start_iteration_process (map_data, process)

	if type(map_data) == "table" then
		
		process(map_data)

		for _, v in pairs(map_data) do
			conversionUtil.start_iteration_process(v, process)
		end
	end
end

--- Iterates through a table if it has the given key
-- 
-- @param 	table 		set 		table of map data to iterate on
-- @param 	string 		key 		the key to check for
-- @param 	function 	process 	function to execute with each set of data, reqiures the params: (table)

function conversionUtil.iterate_sets_with_key(set, key, process)

	if set[key] ~= nil then 

		for k, v in pairs(set[key]) do
			processs(v)
		end
	end
end

--- Removes all instances of the keys found within the given layer types
-- 
-- @param 	table 		set 		table of map data to iterate on
-- @param 	table 		keys 		string table of the keys to remove
-- @param 	table 		layerTypes	optional - table of layers that must match, see the method "matchesType" for formatting

function conversionUtil.remove_keys (set, keys, layerTypes)

	if conversionUtil.matchesType(set, layerTypes) then

		for k, _ in pairs(set) do

			for i = 1, #keys do
				if k == keys[i] then
					set[k] = nil
				end
			end
		end
	end
end

--- Removes keys with empty values
-- 
-- @param 	table 		set 		table of map data to iterate on

function conversionUtil.remove_empty_keys (set)

	if conversionUtil.matchesType(set, layerTypes) then

		for k, v in pairs(set) do

			if util.is_nil_or_empty(v) then
				set[k] = nil
			end
		end
	end
end

--- Adds table entries to the given table if they don't already exist
-- 
-- @param 	table 		set 		table of map data to iterate on
-- @param 	table 		entries		table of entry values to add
-- @param 	table 		layerTypes	optional - table of layers that must match, see the method "matchesType" for formatting

function conversionUtil.add_entries_for_each_layer (set, entries, layerTypes)

	if conversionUtil.matchesType(set, layerTypes) then

		for key, value in pairs(entries) do

			if set[key] == nil then
				set[key] = value
			end
		end
	end
end

--- Converts entries in the given table to new ones with the given conversion method. 
--- Mainly used for converting coords/dimensions
-- 
-- @param 	table 		set 		table of map data to iterate on
-- @param 	table 		old_keys 	string table of the keys to remove
-- @param 	table 		new_keys 	string table of the keys to add
-- @param 	function 	conversion 	function which values are converted through, requires the params: (number, boolean)

function conversionUtil.convert_each_entry (set, old_keys, new_keys, conversion)

	for i = 1, #old_keys do

		if set[old_keys[i]] ~= nil then
			set[new_keys[i]] = conversion(set[old_keys[i]], i %2 == 1)
			set[old_keys[i]] = nil
		end
	end
end

--- Converts Tiled's custom properties from lua to a Tiled readable format
-- 
-- @param 	table 		set 		table of map data to iterate on

function conversionUtil.convert_custom_properties_to_tiled (set)

	if set["properties"] ~= nil then

		local properties = set["properties"]
		local convertedProperties = {}

		for key, value in pairs(properties) do

			if type(value) ~= string then

				local type = tostring(type(value))
				if type == "number" then 
					type = "int"
				end
				table.insert(convertedProperties, 
					{name = tostring(key), 
					type = type, 
					value = value})
			end
		end

		set["properties"] = convertedProperties
	end
end

--- Converts Tiled's custom properties from json to lua format
-- 
-- @param 	table 		set 		table of map data to iterate on

function conversionUtil.convert_custom_properties_to_lua (set)

	if set["properties"] ~= nil then

		local properties = set["properties"]
		local convertedProperties = {}

		for k, v in pairs(properties) do

			convertedProperties[v["name"]] = v["value"]
		end

		set["properties"] = convertedProperties
	end
end

--- Updates tileset image paths and sets margin/spacing
-- 
-- @param 	table 		set 		table of map data to iterate on
-- @param 	string 		path 		directory of image files
-- @param 	number		margin 		margin property for tilesets
-- @param 	number		spacing 	spacing property for tilesets

function conversionUtil.locate_tileset_images (set, path, margin, spacing)

	if not util.is_nil_or_empty(path) then

		local img = set["image"]

		if img ~= nil then

			set["image"] = path .. "\\" .. set["name"] .. ".png"
			set["margin"] = margin
			set["spacing"] = spacing
		end
	end
end

--- Updates tileset image paths and sets margin/spacing
-- 
-- @param 	table 		set 		table of map data to iterate on
-- @param 	string 		path 		directory of image files

function conversionUtil.convert_tileset_paths (set, path)

	if set["image"] ~= nil then 

		local new_path = imgPath:gsub("\\","/") .. util.get_filename(set["image"]) .. ".png"
		set["image"] = new_path
	end
end

--- Adds a table of tiles for map objects from their dimensions
-- 
-- @param 	table 		set 		table of map data to iterate on
-- @param 	string 		key 		object key

function conversionUtil.add_object_tiles (set, key)

	if set[key] ~= nil then 
		local objs = set[key]

		for k, v in pairs(objs) do 

			if v["tiles"] == nil then 
				local w = v["widthInTiles"] - 1 
				local h = v["heightInTiles"] - 1

				local tiles = {}

				for x=0, w do 

					for y=0, h do
						table.insert(tiles, {x,y})
					end
				end

				v["tiles"] = tiles
			end
		end
	end
end

--- checks if the table has a type that matches the given list
---
--- always returns true if the types paramater contains: match = all"
--- returns true if no types are matched while type list contains: match = "exclude"
--- otherwise returns if a match is found or not
--
-- @param 	table 		set 		table of map data to iterate on
-- @param 	table 		layerTypes	table of layers to check for matches

function conversionUtil.matchesType (set, types)

	if types == nil or set == nil or types["match"] == "all"  then 
		return true
	end

	local matching = false
	

	for i = 1, #types do

		if set["type"] == types[i] then

			matching = true
			break 
		end
	end

	if types["match"] == "exclude" then 
		return not matching
	end

	return matching
end

return conversionUtil