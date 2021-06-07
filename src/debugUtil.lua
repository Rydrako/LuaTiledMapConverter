-- Copyright (c) 2021 Rydrako. All rights reserved.
--
-- This file is a part of Lua Tiled Map Converter
-- This work is licensed under the terms of the GPL-3.0 license
-- For a copy, see <https://opensource.org/licenses/GPL-3.0>.

-- Debugging Module
local debugUtil = {}
local util = require("util")

--- Prints out a table and all of its contents to the console
--
-- @param 	table 	_table 			table to print
-- @param 	number	indent			current indentation, only used with recursive calls

function debugUtil.nested_print (_table, indent)

	indent = indent and indent or 0

	if _table == nil then
		print("nil")
	end
	if type(_table) == "table" then
		for key, value in pairs(_table) do
    		print(util._repeat(" ",indent) .. key)
    		debugUtil.nested_print(value, indent + 1)
		end
	else -- print any other vaues
		print(util._repeat(" ",indent) .. " : " .. tostring(_table))
	end
end

--- Prints out an edge in the format: x1,y1 -> x2,y2 to the console
--
-- @param	table  	edge 		the edge to print

function debugUtil.print_edge(edge)

	if edge ~= nil then
		print(edge["x1"] .. " , " .. edge["y1"] .. " -> " .. edge["x2"] .. " , " .. edge["y2"])
	else
		print("nil")
	end
end

return debugUtil