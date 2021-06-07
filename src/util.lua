-- Copyright (c) 2021 Rydrako. All rights reserved.
--
-- This file is a part of Lua Tiled Map Converter
-- This work is licensed under the terms of the GPL-3.0 license
-- For a copy, see <https://opensource.org/licenses/GPL-3.0>.

--- Generic Utility Module
local util = {}
local lfs = require("lfs")

--- returns a string of the provided string repeated by the given amount of times
--
-- @param   string  str     string to repeat
-- @param   number  amount  number of times to repeat str

function util._repeat (str, amount)
    
    local result = ""
    for i = 0, amount, 1 do
        result = result .. str 
    end
    return result
end

--- splits the provided string into an array, split up by the given separator string
--
-- @parm    string   str    string to split
-- @param   string   sep    character/string to split str by

function util.split(str, sep) 

	sep = sep or '%s' 
	local t={}  
	for field,s in string.gmatch(str, "([^"..sep.."]*)("..sep.."?)") do 
		table.insert(t,field)  
		if s=="" then
		 	return t
		 end 
	end 
end

function util.is_nil_or_empty (str)
	return str == nil or str == ""
end

function util.get_parent_path(path)

    pattern1 = "^(.+)//"
    pattern2 = "^(.+)\\"

    if (string.match(path,pattern1) == nil) then
        return string.match(path,pattern2)
    end

    return string.match(path,pattern1)
end

function util.is_dir (path)

    return path:sub(-1) == "/" or lfs.attributes(path, "mode") == "directory"
end

function util.get_filename(path)   

    local dirs = util.split(path, "\\")
    return dirs[#dirs]:match("(.+)%..+")
end

--- Escapes pattern characters in the given string

function util.escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

function util.ends_with(str, end_str)
    return str:sub(-string.len(end_str)) == end_str
end


return util