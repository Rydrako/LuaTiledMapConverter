-- Copyright (c) 2021 Rydrako. All rights reserved.
--
-- This file is a part of Lua Tiled Map Converter
-- This work is licensed under the terms of the GPL-3.0 license
-- For a copy, see <https://opensource.org/licenses/GPL-3.0>.

-- I/O Module
local ioUtil = {}
local util = require("util")
local json = require("JSON")

--- returns a table from a file
--
-- @param 	string 	file 			path of the file to load

function ioUtil.load_file (file)

	local file_data = ""

	if string.match(file, ".json") then 

		local f = io.open(file, "r")
		local contents = f:read("*all")

		file_data = json:decode(contents)

		f:close()
	elseif string.match(file, ".lua") then

		file_data = dofile(file)
	end

	return file_data
end

--- Creates a new file with given data to the specified file location. 
--- file name and extension will be added to path if needed.
--
-- @param 	string 	file 			path of directory or file to export to
-- @param 	table 	file_data		contents to be written to new file
-- @param 	string 	default_name 	default file name
-- @param 	string 	file_extension 	file extension, ".json" or ".lua"

function ioUtil.export_file (file, file_data, default_name, file_extension)

	local is_json = string.match(file, "json")
	local is_lua = string.match(file, ".lua")

	if not string.match(file, "json") and not string.match(file, ".lua") then

		if util.is_dir(file) then 
			file = file .. "\\" .. default_name .. file_extension
		else

			file = file .. file_extension
		end
	end

	if string.match(file, "json") then 

		local f = io.open(file, "w")

		f:write(json:encode_pretty(file_data))
		f:close()
		return true
	elseif  string.match(file, ".lua") then 

		local f = io.open(file, "w")
		print(f)

		ioUtil.write_table(f, file_data)
	
		f:close()
		return true
	else
		return false
	end
end

--- Recursivly writes out the given table to the specified file
-- 
-- @param	file 	file 	file to write to
-- @param 	table 	_table 	table that will be writen
-- @param  	number	ident 	current ident, only used with recursive calls

function ioUtil.write_table (file, _table, indent)

	ident = ident and ident or 0

	if indent == 0 then
		file:write("return {\n")
	end

	local tabs = util._repeat("  ", indent)

	for key, value in pairs(_table) do

		local key_str = type(key) == "number" and "" or key .. " = "

		if type(value) == "table" then

			file:write(tabs .. key_str .. "{\n")
			ioUtil.write_table(file, value, indent+1)
			file:write(tabs .. "},\n")
		else

			local formatted_value = tostring(value)
			if type(value) == "string" then
				formatted_value = value:gsub("\\", "/"):gsub("\"", "\\\"")
			end

			local value_str = type(value) == "string" and '"' .. formatted_value .. '"' or formatted_value

			--removes quotation marks from any formatted boolean values
			if value == "true" or value == "false" then
				value_str = value
			end

			file:write(tabs .. key_str .. value_str .. ",\n")
		end
	end

	if indent == 0 then
		file:write("}")
	end
end

return ioUtil