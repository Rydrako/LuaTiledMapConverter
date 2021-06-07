-- Copyright (c) 2021 Rydrako. All rights reserved.
--
-- This file is a part of Lua Tiled Map Converter
-- This work is licensed under the terms of the GPL-3.0 license
-- For a copy, see <https://opensource.org/licenses/GPL-3.0>.

--- Polygon Conversion Utility Module
local polygonUtil = {}
local debugUtil = require("debugUtil")

--- Converts a polygon value back into a table of tiles
--
-- @param 	table 		set 		table of map data to iterate on
-- @param 	string 		key 		the polygon key
-- @param 	table 		objectTypes	optional - table of object types that must match, see the method "matchesType" in conversionUtil for formatting

function polygonUtil.convert_polygons_to_tiles (set, key, objectTypes)

	local matchesObjectType = false
	for i = 1, #objectTypes do
		if set["type"] == objectTypes[i] then
			matchesObjectType = set[key] ~= nil
			break
		end
	end

	if matchesObjectType then

		--debugUtil.nested_print(set, 0)
		local points = set[key]
		local edges = {}
		local width = data["tilewidth"]
		local height = data["tileheight"]

		local offset_x = 0
		local offset_y = 0

		for _, v in pairs(points) do

			offset_x = math.min(v["x"], offset_x)
			offset_y = math.min(v["y"], offset_y)
		end

		-- apply offset and convert coords to tiles
		for _, v in pairs(points) do
			print(v["x"] .. " , " .. v["y"])
			v["x"] = (v["x"] - offset_x)/width
			v["y"] = (v["y"] - offset_y)/height
		end

		for i=1,#points do

			local nxt = i < #points and i + 1 or 1 
			insert_edge(edges, points[i]["x"], points[i]["y"], points[nxt]["x"], points[nxt]["y"])
		end

		local w = set["width"] and set["width"]/width-0.5 or set["widthInTiles"]-0.5
		local h = set["height"] and set["height"]/height-0.5 or set["heightInTiles"]-0.5
		local tiles = {}

		for y=0.5, h, 1 do

			for x=0.5, w, 1 do
				
				if point_inside_polygon(edges, x, y) then
					table.insert(tiles, 
						{
							(x-0.5), 
							(y-0.5)
						})
				end
			end
			print(str)
		end

		set[key] = nil
		set["tiles"] = tiles
	end
end

--- Converts a table of tiles into a table of points called Polygon that Tiled can parse.
--- This function uses an edge detection algorithm to plot points around the perimeter of the tiles
--- For more details see, <https://github.com/a327ex/blog/issues/5>
-- 
-- @param 	table 		set 		table of map data to iterate on
-- @param 	string 		key 		the polygon key
-- @param 	table 		objectTypes	optional - table of object types that must match, see the method "matchesType" in conversionUtil for formatting

function polygonUtil.convert_tile_data_to_polygons (set, key, objectTypes)

	local matchesObjectType = false
	for i = 1, #objectTypes do
		if set["type"] == objectTypes[i] then
			matchesObjectType = set[key] ~= nil
			break
		end
	end

	if matchesObjectType then
		local tiles = set[key]
		local edges = {}
		local width = data["tilewidth"]
		local height = data["tileheight"]

		for _, v in pairs(tiles) do
			generate_tile_edges(edges, v[1] * width, v[2] * height, width, height)
		end

		merge_edges(edges)

		local offset = get_polygon_offset(edges, set["width"], set["height"])

		-- apply the offset to all points in our edges
		for k, v in pairs(edges) do

			if v ~= nil then
				v["x1"] = v["x1"] - offset["x"]
				v["y1"] = v["y1"] - offset["y"]
				v["x2"] = v["x2"] - offset["x"]
				v["y2"] = v["y2"] - offset["y"]
			end
		end
		
		local sortedEdges = sort_edges(edges)
		local coords = {}

		for _, v in pairs(sortedEdges) do

			if not does_point_exist(coords, v["x1"], v["y1"]) then
				table.insert(coords, { x=v["x1"],  y=v["y1"] })
			end

			if not does_point_exist(coords,v["x2"], v["y2"]) then
				table.insert(coords, { x=v["x2"], y=v["y2"] })
			end
		end

		set[key] = nil
		set["polygon"] = coords
		set["x"] = set["x"] + offset["x"]
		set["y"] = set["y"] + offset["y"]
	end
end

--- Calculates the polygon's offset so its most upper-left coord becomes (0, 0)

function get_polygon_offset (edge_list, width, height)

	local offset = {
			x=width,
			y=height
		}

	for _, v in pairs(edge_list) do
		if v ~= nil then
			local x = math.min(v['x1'], v['x2'])
			local y = math.min(v['y1'], v['y2'])

			if y <= offset["y"] then
				if x < offset["x"] then
					offset["x"] = x
					offset["y"] = y
				end
			end
		end
	end

	return offset
end

--- Sorts the edges in a given list in the order they are connected starting with the edge starting at point (0, 0)

function sort_edges (edge_list)

	local sorted_list = { get_edge_with_point(edge_list, 0, 0) }

	for _, v in pairs(sorted_list) do

		for __, vv in pairs(edge_list) do

			if not does_edge_exist(sorted_list, vv) then

				if (not are_equal_edges(v, vv)) and (v["x2"] == vv["x1"] and v["y2"] == vv["y1"]) then
					table.insert(sorted_list, vv)
					break
				end
			end
		end
	end
	return sorted_list
end

--- Merges all adjacent edges within given list

function merge_edges (edge_list)

	for _,v in pairs(edge_list)  do
		
		if v ~= nil then
			for k, vv in pairs(edge_list) do

				if v ~= vv and vv ~= nil then
					if are_adjacent_edges(v, vv) then
						max_x = math.max(v["x1"], v["x2"], vv["x1"], vv["x2"])
						min_x = math.min(v["x1"], v["x2"], vv["x1"], vv["x2"])
						max_y = math.max(v["y1"], v["y2"], vv["y1"], vv["y2"])
						min_y = math.min(v["y1"], v["y2"], vv["y1"], vv["y2"])

						new_x1 = (v["x1"] ~= v["x2"] and v["x1"] < v["x2"]) and min_x or max_x
						new_x2 = (v["x1"] ~= v["x2"] and v["x1"] < v["x2"]) and max_x or min_x
						new_y1 = (v["y1"] ~= v["y2"] and v["y1"] < v["y2"]) and min_y or max_y
						new_y2 = (v["y1"] ~= v["y2"] and v["y1"] < v["y2"]) and max_y or min_y

						v["x1"] = new_x1
						v["y1"] = new_y1
						v["x2"] = new_x2
						v["y2"] = new_y2

						edge_list[k] = nil
					end
				end
			end
		end
	end
end

--- Generates the 4 edges of each tile

function generate_tile_edges (edge_list, x, y, width, height)

	insert_edge(edge_list, x, y, x + width, y)
	insert_edge(edge_list, x + width, y, x + width, y + height)
	insert_edge(edge_list, x + width, y + height, x, y + height)
	insert_edge(edge_list, x, y + height, x, y)
end


--- Add an edge into the list and removes edges if adding a duplicate edge.
--- Thus how we end up with only the outer edges of the polygon

function insert_edge (edge_list, x1, y1, x2, y2)

	local exists = false
	for k, v in pairs(edge_list) do
		if edge_contains_points(v, x1, y1, x2, y2) then
			exists = true
			edge_list[k] = nil
			break
		end
	end

	if not exists then
		table.insert(edge_list, 
		{
			x1 = x1,
			y1 = y1,
			x2 = x2,
			y2 = y2,
		})
	end
end

function edge_contains_point (edge, x, y)

	return (edge["x1"] == x and edge["y1"] == y) or (edge["x2"] == x and edge["y2"] == y)
end

function edge_contains_points (edge, x1, y1, x2, y2)

	return edge_contains_point(edge, x1, y1) and edge_contains_point(edge, x2, y2) 
end

function are_adjacent_edges (edge, edge2)

	if edge_contains_point(edge, edge2["x1"], edge2["y1"]) or edge_contains_point(edge, edge2["x2"], edge2["y2"]) then

		local delta1 = edge_delta(edge)
		local delta2 = edge_delta(edge2)

		return delta1["x"] == delta2["x"] and delta1["y"] == delta2["y"]
	else
		return false
	end
end

function are_equal_edges (edge, edge2)

	return edge["x1"] == edge2["x1"] and edge["y1"] == edge2["y1"] and edge["x2"] == edge2["x2"] and edge["y2"] == edge2["y2"]
end

function does_point_exist (set, x, y)

	for _, point in pairs(set) do
		if point["x"] == x and point["y"] == y then
			return true
		end
	end
	return false
end

function does_edge_exist (set, edge)

	for _, e in pairs(set) do
		if are_equal_edges(e, edge) then
			return true
		end
	end
	return false
end

function get_edge_with_point (set, x, y)

	for k, v in pairs(set) do
		if v ~= nil then
			if edge_contains_point(v, x, y) then
				return v
			end
		end
	end 
	return nil
end

function edge_delta(edge)

	if edge == nil then
		return { x = 0, y = 0}
	end
	
	local deltax = sign(edge["x2"] - edge["x1"])
	local deltay = sign(edge["y2"] - edge["y1"])
	return {
		x = deltax,
		y = deltay	
	}
end

function sign(number)
	
    return number > 0 and 1 or (number == 0 and 0 or -1)
end

function get_closest_edge (edges, x, y, direction)

	local closest = nil
	local distance = -1
	local vertical = direction == "north" or direction == "south"

	for _, edge in pairs(edges) do

		local within_direction = false

		if direction == "north" then
			within_direction = edge["y1"] < y and edge["y1"] - edge["y2"] == 0
		elseif direction == "south" then
			within_direction = edge["y1"] > y and edge["y1"] - edge["y2"] == 0
		elseif direction == "east" then
			within_direction = edge["x1"] > x and edge["x1"] - edge["x2"] == 0
		elseif direction == "west" then
			within_direction = edge["x1"] < x and edge["x1"] - edge["x2"] == 0
		end

		if within_direction then

			local within_bounds = vertical and within_range(x, edge["x1"], edge["x2"]) or within_range(y, edge["y1"], edge["y2"])

			if within_bounds then

				local new_dist = vertical and math.abs(y - edge["y1"]) or math.abs(x - edge["x1"])

				if new_dist < distance or distance < 0 then
					distance = new_dist
					closest = edge
				end
			end
		end
	end

	return closest
end

function point_inside_polygon(edges, x, y)
	
	return edge_delta(get_closest_edge(edges, x, y, "north"))["x"] == 1 and 
		edge_delta(get_closest_edge(edges, x, y, "south"))["x"] == -1 and
		edge_delta(get_closest_edge(edges, x, y, "east"))["y"] == 1 and
		edge_delta(get_closest_edge(edges, x, y, "west"))["y"] == -1
end

function within_range(value, end1, end2)

	local min = math.min(end1, end2)
	local max = math.max(end1, end2)

	return min <= value and value <= max
end

return polygonUtil