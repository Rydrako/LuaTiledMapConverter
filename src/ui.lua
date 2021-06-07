-- Copyright (c) 2021 Rydrako. All rights reserved.
--
-- This file is a part of Lua Tiled Map Converter
-- This work is licensed under the terms of the GPL-3.0 license
-- For a copy, see <https://opensource.org/licenses/GPL-3.0>.

--- UI Module
local ui = {}
local conversionTool = require("conversionTool")
local uiUtil = require("uiUtil")
local util = require("util")

-- file input fields
file_field = uiUtil.file_input("  *File: ", "30", function (_txt) 

		uiUtil.file_dialog(iup.filedlg{
				dialogtype = "OPEN",
				filter = "*.lua;*.json",
				filterinfo = "Lua & Tiled Files",
				multiplefiles = "Yes"
			},
			_txt)
	end)

export_field = uiUtil.file_input("*Path: ", "30", function (_txt)

		uiUtil.file_dialog(iup.filedlg{
				dialogtype = "DIR"
			},
			_txt)
	end)

img_field = uiUtil.file_input("", "30", function (_txt)

		uiUtil.file_dialog(iup.filedlg{
				dialogtype = "DIR"
			},
			_txt)
	end)

img_field["active"] = "NO"

tileset_field = uiUtil.file_input("   Tileset Path: ", "27", function (_txt)

		uiUtil.file_dialog(iup.filedlg{
				dialogtype = "DIR"
			},
			_txt)
	end)

--Menu items
item_open = iup.item{title="&Open...\tCtrl+O",
	action=(function ()
			file_field.btn.action()
		end)}
item_tiled = iup.item{title="&Export to Tiled\tCtrl+E",
	action=(function ()
			export_field.btn.action()
			export_tiled()
		end)}
item_lua = iup.item{title="&Export to Lua\tCtrl+Shift+E", 
	action=(function ()
		export_field.btn.action()
		export_lua()
	end)}
item_exit = iup.item{title="&Quit\tCtrl+Q", 
	action=(function ()
		return iup.CLOSE
	end)}
item_about = iup.item{title="&About\tCtrl+A"}

-- About Dialog Layout
abt_btn = iup.button{title="OK", expand="HORIZONTAL"}

abt_box = iup.vbox{
		iup.label{title="Lua-Tiled Map Converter", font="Helvetica, 16", alignment="acenter", expand="HORIZONTAL"},
		iup.label{title="Version 0.0.1", font="Helvetica, 8", alignment="acenter", expand="HORIZONTAL"},
		iup.label{title="Copyright © 2021 Rydrako", alignment="acenter", expand="HORIZONTAL"},
		iup.label{title="You may modify and redistribute this program under the terms of the GPL \n(version 3 or later)\nRepo Link:", alignment="acenter", 
			expand="HORIZONTAL"},
		iup.text{value="https://github.com/Rydrako/LuaTiledMapConverter", expand="HORIZONTAL", alignment="acenter", readonly="YES"},
		iup.label{separator="HORIZONTAL"},
		abt_btn,
		alignment="aright",
		margin="10x10",
		gap="10"
	}

abt_dlg = iup.dialog{
		abt_box,
		title = "About",
		size = "QUARTERxQUARTER",
		resize = "NO"
	}

function item_about:action ()
	abt_dlg:showxy(iup.CENTER,iup.CENTER)
end

function abt_btn:action ()
	abt_dlg:hide()
end

package_tgl = iup.toggle{title = "Use package names as directories", value="ON"}

tileset_tgl = iup.toggle{title = "Use Output Path", 
	action=(function (self)
			img_field["active"] = self.value=="ON" and "NO" or "YES"
		end), 
	value="ON"}

margin = iup.text{SPIN="Yes", spinmin=0, rastersize="48x",}
spacing = iup.text{SPIN="Yes", spinmin=0, rastersize="48x"}

-- File and Help Menu
file_menu = iup.menu{item_open, iup.separator{}, item_tiled, item_lua, item_exit}
help_menu = iup.menu{item_about}
sub1_menu = iup.submenu{file_menu, title = "&File"}
sub2_menu = iup.submenu{help_menu, title = "&Help"}
menu = iup.menu{sub1_menu, sub2_menu}

--- Starts the process for converting the file(s) and 
--- returns a table with title and message for an iup pop up
--
-- @param 	function 	process 				the conversion method to execute, requires the params (string, ..), 
--																		see conversionTools methods for details

function export_files (process)

	if util.is_nil_or_empty(file_field.txt.value) then
		return {title="Error", msg="Please enter a valid input file"}
	elseif util.is_nil_or_empty(export_field.txt.value) then
		return {title="Error", msg="Please enter a valid output directory or file name"}
	end

	local files = util.split(file_field.txt.value, "|")

	if #files > 1 then

		local dir = files[1]

		for i=2,#files-1 do

			if not process(dir .. "\\" .. files[i]) then

				return {title="Error", msg="Error occured converting " .. files[i]}
			end
		end

		return {title="Success", msg="Successfully converted " .. #files-1 .. " files!"}
	else

		if not process(file_field.txt.value) then

			return {title="Error", msg="Error occured converting " .. util.get_filename(file_field.txt.value)}
		else

			return {title="Success", msg="Successfully converted " .. util.get_filename(file_field.txt.value)}
		end
	end

	
end

function export_tiled_old ()

	if util.is_nil_or_empty(file_field.txt.value) then
		return {title="Error", msg="Please enter a valid input file"}

	elseif util.is_nil_or_empty(export_field.txt.value) then
		return {title="Error", msg="Please enter a valid output directory or file name"}

	end

	local files = util.split(file_field.txt.value, "|")

	if #files > 1 then

		local dir = files[1]

		for i=2,#files-1 do

			if not conversionTool.toTiled(dir .. "\\" .. files[i],
															export_field.txt.value, 
															tileset_tgl.value=="OFF" and img_field.txt.value or nil, 
															margin.value, spacing.value, 
															package_tgl.value=="ON") then

				return {title="Error", msg="Error occured converting " .. files[i]}
			end
		end

		return {title="Success", msg="Successfully converted " .. #files-1 .. " files!"}
	else

		if not conversionTool.toTiled(file_field.txt.value, 
															export_field.txt.value, 
															tileset_tgl.value=="OFF" and img_field.txt.value or nil, 
															margin.value, spacing.value, 
															package_tgl.value=="ON") then

			return {title="Error", msg="Error occured converting " .. util.get_filename(file_field.txt.value)}
		else

			return {title="Success", msg="Successfully converted " .. util.get_filename(file_field.txt.value)}
		end
	end

	
end

-- Starts conversion process for exporting to lua format
function export_lua_old ()

	if util.is_nil_or_empty(file_field.txt.value) then
		return {title="Error", msg="Please enter a valid input file"}

	elseif util.is_nil_or_empty(export_field.txt.value) then
		return {title="Error", msg="Please enter a valid output directory or file name"}
		
	end

	local files = util.split(file_field.txt.value, "|")

	if #files > 1 then

		local dir = files[1]

		for i=2,#files-1 do

			if not conversionTool.toLua(dir .. "\\" .. files[i], export_field.txt.value, tileset_field.txt.value, package_tgl.value=="ON")then
				
				return {title="Error", "Error occured converting " .. files[i]}
			end
		end
		
		return {title="Success", "Successfully converted " .. #files-1 .. " files!"}
	else

		if conversionTool.toLua(file_field.txt.value, export_field.txt.value, 
															tileset_field.txt.value, package_tgl.value=="ON") then

			return {title="Error", "Error occured converting " .. util.get_filename(file_field.txt.value)}
		else
			return {title="Success", "Successfully converted " .. util.get_filename(file_field.txt.value)}
		end
	end
end

function export_tiled (file)

	return conversionTool.toTiled(file, 
												export_field.txt.value, 
												tileset_tgl.value=="OFF" and img_field.txt.value or nil, 
												margin.value, spacing.value, 
												package_tgl.value=="ON")
end

function export_lua (file)

	return conversionTool.toLua(file, 
											export_field.txt.value, 
											tileset_field.txt.value, 
											package_tgl.value=="ON")
end

-- Main Window layout
vbox = iup.vbox{
	iup.label{title="         Input", fgcolor="100 100 100"},
	iup.label{separator="HORIZONTAL"},
	file_field, --Input section
	iup.label{title="         Output", fgcolor="100 100 100"},
	iup.label{separator="HORIZONTAL"},
	iup.vbox{  --Export section

				export_field,
				iup.hbox{
					package_tgl,
					gap = "10",
					margin = "57x10"
				}
		},
	iup.label{title="         Tileset Settings", fgcolor="100 100 100"},
	iup.label{separator="HORIZONTAL"},
	iup.vbox{ --Tileset Settings section

		iup.hbox{
			iup.label{title="Dir:"},
			tileset_tgl,
			gap = "15",
			margin = "25x10"
		},
		iup.hbox{
			img_field,
			margin = "35x0"
		},
		iup.hbox{

				iup.label{title="Margin: "},
				margin,
				iup.label{title="Spacing: "},
				spacing,
				alignment="acenter",
				gap = "10",
				margin = "10x10"

		}
	},
	iup.label{title="         Lua Settings", fgcolor="100 100 100"},
	iup.label{separator="HORIZONTAL"},
	tileset_field,
	iup.label{title="         Convert", fgcolor="100 100 100"},
	iup.label{separator="HORIZONTAL"},
	iup.hbox{ --Convert section

		iup.button{title="Export to Lua (.lua)", 
			action=(function ()
				local result = export_files(export_lua)

				iup.Message(result["title"], result["msg"])
			end)
		},
		iup.button{title="Export to Tiled (.json)", 
			action=(function ()
				local result = export_files(export_tiled)

				iup.Message(result["title"], result["msg"])
			end)
		},
		alignment="acenter",
		gap = "10",
		margin = "50x10"

	}
}

ui = iup.dialog{
  vbox,
  title = "Lua-Tiled Map Converter",
  size = "QUARTERx250",
  menu = menu,
  resize = "NO"
}

-- Hot keys
function ui:k_any(c)

	if c == iup.K_cO then
		item_open:action()
	elseif c == iup.K_cE then
		item_tiled:action()
	elseif c == iup.K_csE then
		item_lua:action()
	elseif c == iup.K_cA then
		item_about:action()
	elseif c == iup.K_cQ then
		item_exit:action()
	end
end

return ui;